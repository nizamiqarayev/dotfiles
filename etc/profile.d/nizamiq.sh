# shellcheck shell=bash
# vim: ft=bash

# PATH Setup
append_path_tree() {
    local base="$1"
    [ -d "$base" ] || return
    append_path "$base"
    for d in "$base"/*/; do
        [ -d "$d" ] && append_path "${d%/}"
    done
}
append_path_tree "$HOME/.local/bin"
append_path_tree "$HOME/.local/share/nvim/mason/bin"
append_path_tree "$HOME/.local/share/npm/bin"
append_path_tree "$HOME/.local/share/pnpm/bin"
append_path_tree "$HOME/.local/share/cargo/bin"
append_path_tree "$HOME/.local/share/go/bin"
append_path_tree "$HOME/.local/share/luarocks/bin"
append_path_tree "$HOME/Documents/Github/Gists"
export PATH

# XDG Setup
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"

# Default programs
export TERMINAL="st"
export EDITOR="nvim"
export VISUAL="nvim"
export BROWSER="firefox"
export MUSIC_DIR="$HOME/Music"

# Source Setup
source_if_exists() {
    local arg

    for arg; do
        [[ $arg == -* ]] && continue
        [[ -f $arg ]] || return
    done
    # shellcheck disable=SC1090
    source "$@"
}

source_if_exists "$XDG_CONFIG_HOME/fzf/fzfrc"

# Misc
export QT_QPA_PLATFORMTHEME=qt6ct
export NSXIV_OPTS="-aqb"
export MOZ_USE_XINPUT2="1"
