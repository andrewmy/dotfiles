#!/usr/bin/env bash
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP" "$HOME/.config"

backup_item() {
  local target="$1"
  if [ -e "$target" ] || [ -L "$target" ]; then
    local rel="${target#$HOME/}"
    local backup_target="$BACKUP/$rel"
    mkdir -p "$(dirname "$backup_target")"
    mv "$target" "$backup_target"
  fi
}

link_item() {
  local src="$1"
  local target="$2"
  mkdir -p "$(dirname "$target")"
  ln -sfn "$src" "$target"
}

for f in .zshrc .zprofile .zshenv .p10k.zsh .gitconfig; do
  backup_item "$HOME/$f"
  link_item "$REPO/home/$f" "$HOME/$f"
done

backup_item "$HOME/.gitignore"
backup_item "$HOME/.config/nvim"
backup_item "$HOME/.config/mc"
backup_item "$HOME/.config/htop/htoprc"
backup_item "$HOME/.config/git/ignore"
backup_item "$HOME/Library/Application Support/com.mitchellh.ghostty/config"
backup_item "$HOME/Library/Application Support/Code - Insiders/User/settings.json"
backup_item "$HOME/Library/Application Support/Code - Insiders/User/keybindings.json"
backup_item "$HOME/Library/Application Support/Code - Insiders/User/snippets"

link_item "$REPO/config/nvim" "$HOME/.config/nvim"
link_item "$REPO/config/mc" "$HOME/.config/mc"
link_item "$REPO/config/htop/htoprc" "$HOME/.config/htop/htoprc"
link_item "$REPO/config/git/ignore" "$HOME/.config/git/ignore"
link_item "$HOME/.config/git/ignore" "$HOME/.gitignore"

link_item "$REPO/config/ghostty/config" "$HOME/Library/Application Support/com.mitchellh.ghostty/config"
link_item "$REPO/config/vscode-insiders/User/settings.json" "$HOME/Library/Application Support/Code - Insiders/User/settings.json"

if [ -f "$REPO/config/vscode-insiders/User/keybindings.json" ]; then
  link_item "$REPO/config/vscode-insiders/User/keybindings.json" "$HOME/Library/Application Support/Code - Insiders/User/keybindings.json"
fi

if [ -d "$REPO/config/vscode-insiders/User/snippets" ]; then
  link_item "$REPO/config/vscode-insiders/User/snippets" "$HOME/Library/Application Support/Code - Insiders/User/snippets"
fi
