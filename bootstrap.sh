#!/usr/bin/env bash
set -euo pipefail
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if ! xcode-select -p >/dev/null 2>&1; then
  xcode-select --install
  echo "Install Command Line Tools, then re-run bootstrap.sh"
  exit 1
fi

if ! command -v brew >/dev/null 2>&1; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

eval "$(/opt/homebrew/bin/brew shellenv || /usr/local/bin/brew shellenv)"
brew bundle --file="$DOTFILES_DIR/Brewfile"

link() { mkdir -p "$(dirname "$2")"; ln -sfn "$1" "$2"; }

for f in .zshrc .zprofile .zshenv .p10k.zsh .gitconfig .gitignore do
  link "$DOTFILES_DIR/home/$f" "$HOME/$f"
done

link "$DOTFILES_DIR/config/nvim" "$HOME/.config/nvim"
link "$DOTFILES_DIR/config/htop/htoprc" "$HOME/.config/htop/htoprc"
link "$DOTFILES_DIR/config/git/ignore" "$HOME/.config/git/ignore"

if [[ ! -f "$HOME/.zsh_secrets" ]]; then
  echo "Create $HOME/.zsh_secrets manually (not in git)."
fi

