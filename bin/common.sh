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

set_platform_paths() {
  if [[ "$DOTFILES_TARGET" == "darwin" ]]; then
    DOTFILES_VSCODE_USER_DIR="$HOME/Library/Application Support/Code - Insiders/User"
    DOTFILES_GHOSTTY_CONFIG_PATH="$HOME/Library/Application Support/com.mitchellh.ghostty/config"
  else
    DOTFILES_VSCODE_USER_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/Code - Insiders/User"
    DOTFILES_GHOSTTY_CONFIG_PATH="${XDG_CONFIG_HOME:-$HOME/.config}/ghostty/config"
  fi
}
