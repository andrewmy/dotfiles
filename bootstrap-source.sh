#/usr/bin/env bash

REPO="$HOME/Code/dotfiles"
BACKUP="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP" "$HOME/.config"

for f in .zshrc .zprofile .zshenv .p10k.zsh .gitconfig .gitignore; do
  [ -e "$HOME/$f" ] && mv "$HOME/$f" "$BACKUP/"
  ln -sfn "$REPO/home/$f" "$HOME/$f"
done

[ -e "$HOME/.config/nvim" ] && mv "$HOME/.config/nvim" "$BACKUP/"
ln -sfn "$REPO/config/nvim" "$HOME/.config/nvim"

ln -sfn "$REPO/config/git/ignore" "$HOME/.config/git/ignore"
git config --global core.excludesFile "$HOME/.config/git/ignore"
