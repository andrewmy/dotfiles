# Dotfiles

My macOS and Linux dotfiles with a fast setup path:

1. Auto-detect platform (`DOTFILES_TARGET=auto` by default)
2. Install packages from `Brewfile` on macOS
3. Symlink tracked config from `home/` into `$HOME` and `config/` into `$HOME/.config`
4. Keep secrets and machine-specific identity in local-only files

## Setup on a target machine

1. Clone this repo and run bootstrap:

```bash
git clone https://github.com/andrewmy/dotfiles
cd dotfiles
./bin/bootstrap
```

2. Create local-only files (documented below), then restart shell:

```bash
exec zsh
```

`bin/bootstrap` defaults to `DOTFILES_TARGET=auto` (detected from `uname -s`).
You can override with `DOTFILES_TARGET=darwin` or `DOTFILES_TARGET=linux`.

On macOS, it bootstraps Xcode Command Line Tools + Homebrew and runs `brew bundle`.
On Linux, it installs some core tools with `apt`, installs Neovim and eza from upstream binaries, installs Powerlevel10k manually, and manages symlinks.

## Make an existing machine use this config

If your machine already has local config files you want to preserve before linking:

```bash
cd dotfiles
./bin/source
```

This creates a backup directory like `~/.dotfiles-backup-YYYYMMDD-HHMMSS`.

## Local Files

These files are expected to be created manually on each machine:

- `~/.zshrc.local`
  - Machine-local aliases, functions, and interactive shell config
- `~/.zshenv.local`
  - Machine-local environment variables (tokens, private env vars)
- `~/.gitconfig.local`
  - Git identity and personal overrides
  - Example:

```ini
[user]
    name = Your Name
    email = you@example.com
```

- `~/.ssh/`, `~/.aws/`, `~/.kube/`, etc.


## Workflow

1. Edit files in this repo
2. Validate changes locally
3. Commit and push
4. On other machines: `git pull` and re-run `./bin/bootstrap`
