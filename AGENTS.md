## Repo Fast Path

Inspect only relevant paths first:

- bootstrap/setup: `bin/bootstrap`, `bin/common.sh`, `bin/linux.sh`, `packages/Brewfile`, `README.md`
- shell/git/signing: `home/.zsh*`, `home/.gitconfig`, `home/.config/git/`, `app-config/1password/`
- Neovim: `home/.config/nvim/`
- VS Code Insiders: `app-config/vscode-insiders/`, `bin/vscode-insiders-extensions`
- shared tools: `packages/*.txt`, `bin/npm-globals`, `bin/gh-extensions`, `bin/agent-skills`, `home/.agents/.skill-lock.json`
- Ghostty: `app-config/ghostty/config`
- Neru: `home/.config/neru/config.toml`
- agent config: `home/.agents/`, `home/.claude/`, `home/.config/opencode/`

Invariants:

- secrets and untracked overrides stay manual: `~/.zshrc.local`, `~/.zshenv.local`, `~/.gitconfig.local`, `~/.ssh/`
- tracked machine signing config is selected by macOS `LocalHostName` from `home/.config/git/` and `app-config/1password/`
- `bin/bootstrap` is safe to re-run; shared manifest rewrites stay explicit and manual
- symlink list lives in one place: `link_all()` in `bin/common.sh` — both `bin/bootstrap` and `bin/source` call it; never add links directly to those scripts
- Linux package/bootstrap behavior lives in `bin/linux.sh`; do not duplicate its package list here
- Neovim bootstrap clears Treesitter parser dirs, then runs `Lazy! restore` and `TSUpdate`

Risky files:

- `bin/common.sh`: destination paths per OS
- `bin/bootstrap`: setup behavior for every machine
- `bin/linux.sh`: fresh Linux bootstrap
- `packages/Brewfile`: shared macOS packages
- `home/.config/nvim/lazy-lock.json`: broad plugin behavior
- `home/.agents/AGENTS.md`, `home/.agents/.skill-lock.json`: global agent behavior and installed skills
- `home/.config/git/`, `app-config/1password/`: machine identity and commit signing
