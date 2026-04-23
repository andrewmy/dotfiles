#!/usr/bin/env bash

run_as_root() {
  if [[ "$(id -u)" -eq 0 ]]; then
    "$@"
  else
    sudo "$@"
  fi
}

version_ge() {
  local current="$1"
  local required="$2"
  [[ "$(printf '%s\n%s\n' "$required" "$current" | sort -V | head -n1)" == "$required" ]]
}

install_linux_apt_packages() {
  local packages=(build-essential cargo fzf bat zoxide ripgrep)
  local missing=()
  local pkg
  for pkg in "${packages[@]}"; do
    if ! dpkg -s "$pkg" >/dev/null 2>&1; then
      missing+=("$pkg")
    fi
  done

  if [[ "${#missing[@]}" -eq 0 ]]; then
    return
  fi

  if ! run_as_root apt-get update; then
    echo "Skipping apt package install: failed to refresh package index."
    return
  fi
  for pkg in "${missing[@]}"; do
    if ! run_as_root apt-get install -y "$pkg"; then
      echo "Failed to install apt package: $pkg"
    fi
  done
}

install_tree_sitter_cli_linux() {
  if command -v tree-sitter >/dev/null 2>&1; then
    return
  fi

  if ! command -v cargo >/dev/null 2>&1; then
    echo "Skipping tree-sitter-cli install: cargo not available."
    return
  fi

  export PATH="$HOME/.cargo/bin:$HOME/.local/bin:$PATH"

  if ! cargo install --locked tree-sitter-cli; then
    echo "Skipping tree-sitter-cli install: cargo install failed."
    return
  fi

  if [[ -x "$HOME/.cargo/bin/tree-sitter" ]]; then
    mkdir -p "$HOME/.local/bin"
    ln -sfn "$HOME/.cargo/bin/tree-sitter" "$HOME/.local/bin/tree-sitter"
  fi
}

linux_arch() {
  case "$(uname -m)" in
    x86_64) echo "x86_64" ;;
    aarch64 | arm64) echo "arm64" ;;
    *) echo "" ;;
  esac
}

eza_asset_target() {
  case "$(uname -m)" in
    x86_64) echo "x86_64-unknown-linux-gnu" ;;
    aarch64 | arm64) echo "aarch64-unknown-linux-gnu" ;;
    armv7l) echo "arm-unknown-linux-gnueabihf" ;;
    *) echo "" ;;
  esac
}

install_neovim_linux() {
  local required_version="0.11.2"
  if command -v nvim >/dev/null 2>&1; then
    local current_version
    current_version="$(
      nvim --version 2>/dev/null | head -n1 | awk '{print $2}' | sed 's/^v//'
    )"
    if [[ -n "$current_version" ]] && version_ge "$current_version" "$required_version"; then
      return
    fi
  fi

  if ! command -v curl >/dev/null 2>&1 || ! command -v tar >/dev/null 2>&1; then
    echo "Skipping Neovim install: curl/tar not available."
    return
  fi

  local arch
  arch="$(linux_arch)"
  if [[ -z "$arch" ]]; then
    echo "Skipping Neovim install: unsupported architecture $(uname -m)."
    return
  fi

  local nvim_asset="nvim-linux-${arch}.tar.gz"
  local tmp_dir
  tmp_dir="$(mktemp -d)"
  local archive="$tmp_dir/$nvim_asset"
  local extracted_dir="$tmp_dir/nvim-linux-${arch}"
  local install_root="${XDG_DATA_HOME:-$HOME/.local/share}/dotfiles"
  local install_dir="$install_root/nvim-linux-${arch}"

  if ! curl -fsSL -o "$archive" "https://github.com/neovim/neovim/releases/latest/download/$nvim_asset"; then
    echo "Skipping Neovim install: failed to download $nvim_asset."
    return
  fi
  if ! tar -xzf "$archive" -C "$tmp_dir"; then
    echo "Skipping Neovim install: failed to extract $nvim_asset."
    return
  fi
  if [[ ! -x "$extracted_dir/bin/nvim" ]]; then
    echo "Skipping Neovim install: extracted binary not found."
    return
  fi

  mkdir -p "$install_root" "$HOME/.local/bin"
  if [[ -d "$install_dir" ]]; then
    mv "$install_dir" "$install_root/nvim-linux-${arch}.old.$(date +%s)"
  fi
  if ! mv "$extracted_dir" "$install_dir"; then
    echo "Skipping Neovim install: failed to move files into place."
    return
  fi
  ln -sfn "$install_dir/bin/nvim" "$HOME/.local/bin/nvim"
}

install_eza_linux() {
  if command -v eza >/dev/null 2>&1; then
    return
  fi

  if ! command -v curl >/dev/null 2>&1 || ! command -v tar >/dev/null 2>&1; then
    echo "Skipping eza install: curl/tar not available."
    return
  fi

  local target
  target="$(eza_asset_target)"
  if [[ -z "$target" ]]; then
    echo "Skipping eza install: unsupported architecture $(uname -m)."
    return
  fi

  local tmp_dir
  tmp_dir="$(mktemp -d)"
  local archive="$tmp_dir/eza.tar.gz"
  if ! curl -fsSL -o "$archive" "https://github.com/eza-community/eza/releases/latest/download/eza_${target}.tar.gz"; then
    echo "Skipping eza install: failed to download eza_${target}.tar.gz."
    return
  fi
  if ! tar -xzf "$archive" -C "$tmp_dir"; then
    echo "Skipping eza install: failed to extract release archive."
    return
  fi
  if [[ ! -x "$tmp_dir/eza" ]]; then
    echo "Skipping eza install: extracted binary not found."
    return
  fi

  mkdir -p "$HOME/.local/bin"
  install -m 0755 "$tmp_dir/eza" "$HOME/.local/bin/eza"
}

install_powerlevel10k_linux() {
  local p10k_dir="${XDG_DATA_HOME:-$HOME/.local/share}/powerlevel10k"
  if [[ -e "$p10k_dir" ]]; then
    return
  fi

  mkdir -p "$(dirname "$p10k_dir")"
  if ! git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$p10k_dir"; then
    echo "Skipping powerlevel10k install on linux: git clone failed."
  fi
}

bootstrap_linux_tools() {
  install_linux_apt_packages
  install_neovim_linux
  install_tree_sitter_cli_linux
  install_eza_linux
  install_powerlevel10k_linux
}
