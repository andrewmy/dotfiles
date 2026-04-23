# Dotfiles

My macOS and Linux dotfiles with a fast setup path:

1. Auto-detect platform (`DOTFILES_TARGET=auto` by default)
2. Install packages from `packages/Brewfile` on macOS
3. Symlink tracked config from `home/` into `$HOME`, with XDG files under `home/.config/` and app-specific exceptions under `app-config/`
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
If you want Treesitter-based Neovim plugins such as `nvim-ts-autotag` to work on Debian/Ubuntu, install `build-essential` manually. The bootstrap scripts do not install a C compiler.

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

## VS Code Extensions

```Shell
./bin/vscode-insiders-extensions update
./bin/vscode-insiders-extensions install
./bin/vscode-insiders-extensions sync
```

`update` overwrites the manifest from the current machine.
`install` is add-only and installs anything missing from the manifest.
`sync` is strict and uninstalls anything not listed in the manifest.

`./bin/bootstrap` runs the add-only `install` step automatically.
`update` stays manual so one machine does not silently rewrite the shared manifest.
