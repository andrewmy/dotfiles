# Lazy-load thefuck on first use.
fuck() {
    unfunction fuck 2>/dev/null
    eval "$(thefuck --alias)"
    fuck "$@"
}
