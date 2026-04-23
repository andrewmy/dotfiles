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

[[ -r "$HOME/.zsh/keybindings.zsh" ]] && source "$HOME/.zsh/keybindings.zsh"
if [[ -d "$HOME/.zsh/functions" ]]; then
    for zsh_function_file in "$HOME/.zsh/functions/"*.zsh(N); do
        source "$zsh_function_file"
    done
    unset zsh_function_file
fi

export DOCKER_BUILDKIT=1

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
alias ll="ls --color=auto -h -H --group-directories-first --time-style=long-iso -lA"
alias serena_list="lsof -iTCP -sTCP:LISTEN | grep 2428"

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

export FZF_DEFAULT_OPTS="--height 40% --border"
export WICK_TELEMETRY=0
export RTK_TELEMETRY_DISABLED=1

[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
