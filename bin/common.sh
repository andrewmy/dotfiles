#!/usr/bin/env bash

DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DOTFILES_TARGET="${DOTFILES_TARGET:-auto}"

detect_os() {
  case "$(uname -s)" in
    Darwin) echo "darwin" ;;
    Linux) echo "linux" ;;
    *) echo "unknown" ;;
  esac
}

resolve_target() {
  if [[ "$DOTFILES_TARGET" == "auto" ]]; then
    DOTFILES_TARGET="$(detect_os)"
  fi

  if [[ "$DOTFILES_TARGET" != "darwin" && "$DOTFILES_TARGET" != "linux" ]]; then
    echo "Unsupported target '$DOTFILES_TARGET'. Use auto, darwin, or linux via DOTFILES_TARGET."
    exit 1
  fi
}

resolve_machine() {
  MACHINE=""
  MACHINE_PROFILE=""
  if [[ "$DOTFILES_TARGET" == "darwin" ]]; then
    MACHINE="$(scutil --get LocalHostName 2>/dev/null | tr '[:upper:]' '[:lower:]' || true)"
    MACHINE_PROFILE="$MACHINE"
    [[ "$MACHINE" != "suanpan" ]] || MACHINE_PROFILE="abacus"
  fi
}

report_unmanaged_brew_packages() {
  local unmanaged_formulae unmanaged_casks

  unmanaged_formulae="$(
    comm -23 \
      <(brew list --formula --installed-on-request | sort -u) \
      <(sed -En 's/^[[:space:]]*brew[[:space:]]+"([^"]+)".*/\1/p' "$@" | sed 's|.*/||' | sort -u)
  )"
  unmanaged_casks="$(
    comm -23 \
      <(brew list --cask | sort -u) \
      <(sed -En 's/^[[:space:]]*cask[[:space:]]+"([^"]+)".*/\1/p' "$@" | sed 's|.*/||' | sort -u)
  )"

  if [[ -n "$unmanaged_formulae" ]]; then
    echo "Homebrew formulae not in active Brewfiles:"
    printf '%s\n' "$unmanaged_formulae"
  fi
  if [[ -n "$unmanaged_casks" ]]; then
    echo "Homebrew casks not in active Brewfiles:"
    printf '%s\n' "$unmanaged_casks"
  fi
}

# Single source of truth for symlinks. $1 is the link function:
# `link` (bootstrap, refuses real dirs) or `link_with_backup` (source).
# Caller must have run resolve_target, resolve_machine, set_platform_paths.
link_all() {
  local L="$1"
  local HOME_CONFIG_ROOT="$DOTFILES_ROOT/home/.config"
  local APP_CONFIG_ROOT="$DOTFILES_ROOT/app-config"
  local f skill_dir

  for f in .zshrc .zprofile .zshenv .p10k.zsh .gitconfig; do
    "$L" "$DOTFILES_ROOT/home/$f" "$HOME/$f"
  done
  "$L" "$DOTFILES_ROOT/home/.zsh/functions" "$HOME/.zsh/functions"
  "$L" "$DOTFILES_ROOT/home/.zsh/keybindings.zsh" "$HOME/.zsh/keybindings.zsh"

  "$L" "$DOTFILES_ROOT/home/.claude/settings.json" "$HOME/.claude/settings.json"
  "$L" "$DOTFILES_ROOT/home/.claude/statusline-command.sh" "$HOME/.claude/statusline-command.sh"
  "$L" "$DOTFILES_ROOT/home/.claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"

  "$L" "$DOTFILES_ROOT/home/.agents/AGENTS.md" "$HOME/.agents/AGENTS.md"
  "$L" "$DOTFILES_ROOT/home/.agents/RTK.md" "$HOME/.agents/RTK.md"
  "$L" "$DOTFILES_ROOT/home/.agents/.skill-lock.json" "$HOME/.agents/.skill-lock.json"
  for skill_dir in "$DOTFILES_ROOT"/home/.agents/skills/*/; do
    "$L" "${skill_dir%/}" "$HOME/.agents/skills/$(basename "$skill_dir")"
  done

  "$L" "$HOME_CONFIG_ROOT/nvim" "$HOME/.config/nvim"
  "$L" "$HOME_CONFIG_ROOT/mc" "$HOME/.config/mc"
  "$L" "$HOME_CONFIG_ROOT/gh/config.yml" "$HOME/.config/gh/config.yml"
  "$L" "$HOME_CONFIG_ROOT/gh-dash/config.yml" "$HOME/.config/gh-dash/config.yml"
  "$L" "$HOME_CONFIG_ROOT/htop/htoprc" "$HOME/.config/htop/htoprc"
  "$L" "$HOME_CONFIG_ROOT/git/ignore" "$HOME/.config/git/ignore"
  "$L" "$HOME_CONFIG_ROOT/git/allowed_signers" "$HOME/.config/git/allowed_signers"
  "$L" "$HOME_CONFIG_ROOT/git/dotfiles.gitconfig" "$HOME/.config/git/dotfiles.gitconfig"
  "$L" "$HOME_CONFIG_ROOT/zed/settings.json" "$HOME/.config/zed/settings.json"
  "$L" "$HOME_CONFIG_ROOT/opencode/opencode.json" "$HOME/.config/opencode/opencode.json"
  "$L" "$HOME_CONFIG_ROOT/neru/config.toml" "$HOME/.config/neru/config.toml"

  # Profile configs selected by LocalHostName (set via: sudo scutil --set LocalHostName <machine>)
  if [[ "$DOTFILES_TARGET" == "darwin" ]]; then
    if [[ -f "$HOME_CONFIG_ROOT/git/$MACHINE_PROFILE.gitconfig" ]]; then
      "$L" "$HOME_CONFIG_ROOT/git/$MACHINE_PROFILE.gitconfig" "$HOME/.config/git/machine.gitconfig"
    else
      echo "No Git config for profile '${MACHINE_PROFILE:-unknown}' — set LocalHostName or add home/.config/git/$MACHINE_PROFILE.gitconfig"
    fi
    if [[ -f "$APP_CONFIG_ROOT/1password/agent.$MACHINE_PROFILE.toml" ]]; then
      "$L" "$APP_CONFIG_ROOT/1password/agent.$MACHINE_PROFILE.toml" "$HOME/.config/1Password/ssh/agent.toml"
    fi
  fi

  "$L" "$APP_CONFIG_ROOT/ghostty/config" "$DOTFILES_GHOSTTY_CONFIG_PATH"
  "$L" "$APP_CONFIG_ROOT/vscode-insiders/User/settings.json" "$DOTFILES_VSCODE_USER_DIR/settings.json"
  if [[ -f "$APP_CONFIG_ROOT/vscode-insiders/User/keybindings.json" ]]; then
    "$L" "$APP_CONFIG_ROOT/vscode-insiders/User/keybindings.json" "$DOTFILES_VSCODE_USER_DIR/keybindings.json"
  fi
  if [[ -d "$APP_CONFIG_ROOT/vscode-insiders/User/snippets" ]]; then
    "$L" "$APP_CONFIG_ROOT/vscode-insiders/User/snippets" "$DOTFILES_VSCODE_USER_DIR/snippets"
  fi

  "$L" "$HOME/.config/git/ignore" "$HOME/.gitignore"
}

set_platform_paths() {
  if [[ "$DOTFILES_TARGET" == "darwin" ]]; then
    DOTFILES_VSCODE_USER_DIR="$HOME/Library/Application Support/Code - Insiders/User"
    DOTFILES_VSCODE_EXTENSIONS_DIR="$HOME/.vscode-insiders/extensions"
    DOTFILES_GHOSTTY_CONFIG_PATH="$HOME/Library/Application Support/com.mitchellh.ghostty/config"
  else
    DOTFILES_VSCODE_USER_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/Code - Insiders/User"
    DOTFILES_VSCODE_EXTENSIONS_DIR="$HOME/.vscode-insiders/extensions"
    DOTFILES_GHOSTTY_CONFIG_PATH="${XDG_CONFIG_HOME:-$HOME/.config}/ghostty/config"
  fi
}
