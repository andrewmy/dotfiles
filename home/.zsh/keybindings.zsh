bindkey -e

autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

# Map arrows/Home/End across terminals using terminfo first, with common fallbacks.
if [[ -n "${terminfo[kcuu1]-}" ]]; then
    bindkey "${terminfo[kcuu1]}" up-line-or-beginning-search
fi
if [[ -n "${terminfo[kcud1]-}" ]]; then
    bindkey "${terminfo[kcud1]}" down-line-or-beginning-search
fi
if [[ -n "${terminfo[khome]-}" ]]; then
    bindkey "${terminfo[khome]}" beginning-of-line
fi
if [[ -n "${terminfo[kend]-}" ]]; then
    bindkey "${terminfo[kend]}" end-of-line
fi
if [[ -n "${terminfo[kdch1]-}" ]]; then
    bindkey "${terminfo[kdch1]}" delete-char
fi
if [[ -n "${terminfo[kpp]-}" ]]; then
    bindkey "${terminfo[kpp]}" up-line-or-beginning-search
fi
if [[ -n "${terminfo[knp]-}" ]]; then
    bindkey "${terminfo[knp]}" down-line-or-beginning-search
fi

bindkey "^[[A" up-line-or-beginning-search
bindkey "^[[B" down-line-or-beginning-search
bindkey "^[OA" up-line-or-beginning-search
bindkey "^[OB" down-line-or-beginning-search
bindkey "\e[H" beginning-of-line
bindkey "\e[F" end-of-line
bindkey "\e[3~" delete-char
bindkey "\e[5~" up-line-or-beginning-search
bindkey "\e[6~" down-line-or-beginning-search

bindkey '^]' docker-fzf-widget
