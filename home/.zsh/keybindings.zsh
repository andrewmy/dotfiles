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
