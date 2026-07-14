# shellcheck shell=bash
# vim: ft=bash

# PATH Setup
if [ -d "$HOME/.local/bin" ]; then
    append_path "$HOME/.local/bin"
    for d in "$HOME/.local/bin"/*/; do
        [ -d "$d" ] && append_path "${d%/}"
    done
fi
if [ -d "$HOME/.local/bin/scripts" ]; then
    append_path "$HOME/.local/bin/scripts"
    for d in "$HOME/.local/bin/scripts"/*/; do
        [ -d "$d" ] && append_path "${d%/}"
    done
fi
if [ -d "$HOME/.local/bin/statusbar" ]; then
    append_path "$HOME/.local/bin/statusbar"
    for d in "$HOME/.local/bin/statusbar"/*/; do
        [ -d "$d" ] && append_path "${d%/}"
    done
fi
if [ -d "$HOME/.local/bin/statusbar" ]; then
    append_path "$HOME/.local/bin/statusbar"
    for d in "$HOME/.local/bin/statusbar"/*/; do
        [ -d "$d" ] && append_path "${d%/}"
    done
fi
if [ -d "$HOME/.local/share/npm/bin" ]; then
    append_path "$HOME/.local/share/npm/bin"
    for d in "$HOME/.local/share/npm/bin"/*/; do
        [ -d "$d" ] && append_path "${d%/}"
    done
fi
if [ -d "$HOME/.local/share/cargo/bin" ]; then
    append_path "$HOME/.local/share/cargo/bin"
    for d in "$HOME/.local/share/cargo/bin"/*/; do
        [ -d "$d" ] && append_path "${d%/}"
    done
fi
if [ -d "$HOME/.local/share/go/bin" ]; then
    append_path "$HOME/.local/share/go/bin"
    for d in "$HOME/.local/share/go/bin"/*/; do
        [ -d "$d" ] && append_path "${d%/}"
    done
fi
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
