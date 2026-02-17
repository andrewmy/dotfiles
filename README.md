# Dotfiles

My macOS dotfiles with a fast setup path:

1. Install packages from `Brewfile`
2. Symlink tracked config from `home/` into `$HOME` and `config/` into `$HOME/.config`
3. Keep secrets and machine-specific identity in local-only files

## Setup on a target Mac

1. Setup CLI tools and clone this repo:

```bash
xcode-select --install
git clone https://github.com/andrewmy/dotfiles
cd dotfiles
./bootstrap.sh
```

2. Create local-only files (documented below), then restart shell:

```bash
exec zsh
```

## Make an existing Mac use this config

If your machine already has local config files you want to preserve before linking:

```bash
cd dotfiles
./bootstrap-source.sh
```

This creates a backup directory like `~/.dotfiles-backup-YYYYMMDD-HHMMSS`.

## Local Files

These files are expected to be created manually on each machine:

- `~/.zsh_secrets`
  - Shell secrets and machine-local exports (tokens, private env vars)
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
4. On the other Macs: `git pull` and re-run `./bootstrap.sh`
