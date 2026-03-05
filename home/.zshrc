# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

typeset -a p10k_theme_candidates
p10k_theme_candidates=(
    /opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme
    /usr/local/share/powerlevel10k/powerlevel10k.zsh-theme
    "${XDG_DATA_HOME:-$HOME/.local/share}/powerlevel10k/powerlevel10k.zsh-theme"
)
for p10k_theme in "${p10k_theme_candidates[@]}"; do
    if [[ -r "$p10k_theme" ]]; then
        source "$p10k_theme"
        break
    fi
done
unset p10k_theme p10k_theme_candidates

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

typeset -U path PATH
path=(
    "$HOME/.local/bin"
    "$HOME/Miniforge3/bin"
    "$HOME/.antigravity/antigravity/bin"
    "$HOME/.yarn/bin"
    "$HOME/.config/yarn/global/node_modules/.bin"
    "$HOME/.composer/vendor/bin"
    "$HOME/.lmstudio/bin"
    $path
)
export PATH
# in a .zshrc.local file:
# path=("$HOME/some/bin" $path)

fpath=("$HOME/.zsh/comp" $fpath)
autoload -Uz compinit && compinit

autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

# Map arrows/Home/End across terminals using terminfo first, with common fallbacks.
for keymap in emacs viins; do
    if [[ -n "${terminfo[kcuu1]-}" ]]; then
        bindkey -M "$keymap" "${terminfo[kcuu1]}" up-line-or-beginning-search
    fi
    if [[ -n "${terminfo[kcud1]-}" ]]; then
        bindkey -M "$keymap" "${terminfo[kcud1]}" down-line-or-beginning-search
    fi
    if [[ -n "${terminfo[khome]-}" ]]; then
        bindkey -M "$keymap" "${terminfo[khome]}" beginning-of-line
    fi
    if [[ -n "${terminfo[kend]-}" ]]; then
        bindkey -M "$keymap" "${terminfo[kend]}" end-of-line
    fi

    bindkey -M "$keymap" "^[[A" up-line-or-beginning-search
    bindkey -M "$keymap" "^[[B" down-line-or-beginning-search
    bindkey -M "$keymap" "^[OA" up-line-or-beginning-search
    bindkey -M "$keymap" "^[OB" down-line-or-beginning-search
    bindkey -M "$keymap" "\e[H" beginning-of-line
    bindkey -M "$keymap" "\e[F" end-of-line
done

# Lazy-load thefuck on first use.
fuck() {
    unfunction fuck 2>/dev/null
    eval "$(thefuck --alias)"
    fuck "$@"
}

# Lazy-load lunchy completion and then delegate to the real command.
lunchy() {
    unfunction lunchy 2>/dev/null

    if (( $+commands[gem] )); then
        local lunchy_gem lunchy_dir completion_file
        lunchy_gem="$(gem which lunchy 2>/dev/null)"
        if [[ -n "$lunchy_gem" ]]; then
            lunchy_dir="$(dirname "$lunchy_gem")/../extras"
            completion_file="$lunchy_dir/lunchy-completion.zsh"
            [[ -r "$completion_file" ]] && source "$completion_file"
        fi
    fi

    command lunchy "$@"
}

export DOCKER_BUILDKIT=1

git_just_pull() {
    if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        echo "git_just_pull: not inside a git repository" >&2
        return 1
    fi

    local stashed=0
    local has_untracked=0

    if [[ -n "$(git ls-files --others --exclude-standard 2>/dev/null)" ]]; then
        has_untracked=1
    fi

    if ! git diff --quiet || ! git diff --cached --quiet || (( has_untracked )); then
        if ! git stash push -u -m "auto-stash before git_just_pull" >/dev/null; then
            echo "git_just_pull: failed to stash local changes" >&2
            return 1
        fi
        stashed=1
    fi

    if ! git pull --ff-only; then
        if (( stashed )); then
            echo "git_just_pull: pull failed; local changes are stashed. Use 'git stash list' and 'git stash pop' when ready." >&2
        fi
        return 1
    fi

    if (( stashed )); then
        if ! git stash pop; then
            echo "git_just_pull: pull succeeded but stash pop reported conflicts." >&2
            return 1
        fi
    fi
}

alias phpqa='docker run --init -it --rm -v $(pwd):/project -v $(pwd)/tmp-phpqa:/tmp -w /project jakzal/phpqa:alpine'
alias stern-prod='stern --namespace prod --kubeconfig ~/.kube/awsconfig-prod'
alias serena='uvx --from git+https://github.com/oraios/serena serena'
if (( $+commands[mactop] )); then
    alias top=mactop
fi
if (( $+commands[bat] )); then
    alias cat=bat
elif (( $+commands[batcat] )); then
    alias cat=batcat
fi
alias vim=nvim
if (( $+commands[eza] )); then
    alias ls=eza
fi
alias du=ncdu
alias ll="ls --color=auto -h -H --group-directories-first --time-style=long-iso -l"
alias serena_sse="uvx --from git+https://github.com/oraios/serena serena start-mcp-server --context codex --project $(pwd) --transport streamable-http --port 9121"

zstyle ':completion:*' menu select
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/compcache"
zstyle ':completion:*' matcher-list \
    'm:{a-zA-Z}={A-Za-z}' \
    'r:|[._-]=* r:|=*' \
    'l:|=* r:|=*'

setopt hist_ignore_dups share_history inc_append_history extended_history
# Remove / from word characters so Ctrl+W and Alt+B/F stop at path separators
WORDCHARS=${WORDCHARS/\/}

if (( $+commands[rv] )); then
    eval "$(rv shell init zsh)"
    eval "$(rv shell completions zsh)"
fi

[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
