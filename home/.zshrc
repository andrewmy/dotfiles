# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

source /opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

typeset -U path PATH
path=(
    "$HOME/Miniforge3/bin"
    "$HOME/.antigravity/antigravity/bin"
    "$HOME/.yarn/bin"
    "$HOME/.config/yarn/global/node_modules/.bin"
    "$HOME/.composer/vendor/bin"
    "$HOME/.lmstudio/bin"
    $path
)
export PATH

fpath=("$HOME/.zsh/comp" $fpath)
autoload -Uz compinit && compinit

autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey "^[[A" up-line-or-beginning-search
bindkey "^[[B" down-line-or-beginning-search
bindkey "\e[H" beginning-of-line
bindkey "\e[F" end-of-line

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

if [[ -r "$HOME/.zsh_secrets" ]]; then
    source "$HOME/.zsh_secrets"
fi

alias phpqa='docker run --init -it --rm -v $(pwd):/project -v $(pwd)/tmp-phpqa:/tmp -w /project jakzal/phpqa:alpine'
alias stern-prod='stern --namespace prod --kubeconfig ~/.kube/awsconfig-prod'
alias serena='uvx --from git+https://github.com/oraios/serena serena'
alias top=mactop
alias cat=bat
alias vim=nvim
alias ll="ls -lah"
alias serena_sse="uvx --from git+https://github.com/oraios/serena serena start-mcp-server --context codex --project $(pwd) --transport streamable-http --port 9121"

zstyle ':completion:*' menu select
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/compcache"
zstyle ':completion:*' matcher-list \
    'm:{a-zA-Z}={A-Za-z}' \
    'r:|[._-]=* r:|=*' \
    'l:|=* r:|=*'

setopt hist_ignore_dups share_history inc_append_history extended_history
WORDCHARS=${WORDCHARS/\/}
