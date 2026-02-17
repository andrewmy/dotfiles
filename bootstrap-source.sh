#!/usr/bin/env bash
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP" "$HOME/.config"

for f in .zshrc .zprofile .zshenv .p10k.zsh .gitconfig; do
  [ -e "$HOME/$f" ] && mv "$HOME/$f" "$BACKUP/"
  ln -sfn "$REPO/home/$f" "$HOME/$f"
done

if [ -e "$HOME/.gitignore" ] || [ -L "$HOME/.gitignore" ]; then
  mv "$HOME/.gitignore" "$BACKUP/"
fi

[ -e "$HOME/.config/nvim" ] && mv "$HOME/.config/nvim" "$BACKUP/"
ln -sfn "$REPO/config/nvim" "$HOME/.config/nvim"

ln -sfn "$REPO/config/git/ignore" "$HOME/.config/git/ignore"
ln -sfn "$HOME/.config/git/ignore" "$HOME/.gitignore"
git config --global core.excludesFile "$HOME/.config/git/ignore"
