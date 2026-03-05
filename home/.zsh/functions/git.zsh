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
