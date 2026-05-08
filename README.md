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
On Linux, it installs some core tools with `apt` (including `build-essential`), installs Neovim and eza from upstream binaries, installs Powerlevel10k manually, and manages symlinks.

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

## Shared Tool Manifests

```Shell
./bin/vscode-insiders-extensions update
./bin/vscode-insiders-extensions install
./bin/vscode-insiders-extensions sync

./bin/npm-globals update
./bin/npm-globals install
./bin/npm-globals sync

./bin/gh-extensions update
./bin/gh-extensions install
./bin/gh-extensions upgrade
./bin/gh-extensions sync

./bin/agent-skills update
./bin/agent-skills install
./bin/agent-skills upgrade
./bin/agent-skills sync
```

These helpers use the same basic shape:

- `update` overwrites the tracked manifest from the current machine
- `install` is add-only and installs anything missing from the manifest
- `sync` is strict and uninstalls anything not listed in the manifest, except `agent-skills`, where global skills are only restored/upgraded

`gh-extensions` also has `upgrade`, which runs `gh extension upgrade --all`.
`agent-skills` tracks the skills CLI global lock at `home/.agents/.skill-lock.json` and links it to `~/.agents/.skill-lock.json`.

`./bin/bootstrap` runs the add-only `install` step automatically for all helpers, then upgrades installed GitHub CLI extensions and agent skills.
`update` stays manual so one machine does not silently rewrite the shared manifest.
