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
