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
  if [[ "$DOTFILES_TARGET" == "darwin" ]]; then
    MACHINE="$(scutil --get LocalHostName 2>/dev/null | tr '[:upper:]' '[:lower:]' || true)"
  fi
}

brew_profile_for_machine() {
  case "$1" in
    abacus | suanpan) echo "abacus" ;;
    salmon) echo "salmon" ;;
    *) return 1 ;;
  esac
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
