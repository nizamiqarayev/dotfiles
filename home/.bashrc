# shellcheck shell=bash
# vim: ft=bash

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

source_if_exists() {
    local arg
    for arg; do
        [[ $arg == -* ]] && continue
        [[ -f $arg ]] || return
    done
    # shellcheck disable=SC1090
    source "$@"
}

# vi mode
set -o vi

# PS1 and PROMPT_COMMAND
PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME}:${PWD/#$HOME/\~}\007"'
eval "$(starship init bash)"

source_if_exists "$XDG_CONFIG_HOME/bash/xdg"
source_if_exists "$XDG_CONFIG_HOME/bash/path"
source_if_exists "$XDG_CONFIG_HOME/bash/sources"
source_if_exists "$XDG_CONFIG_HOME/bash/colors"
source_if_exists "$XDG_CONFIG_HOME/bash/aliases"
source_if_exists "$XDG_CONFIG_HOME/bash/functions"
source_if_exists "$XDG_CONFIG_HOME/bash/clipboard"
source_if_exists "$XDG_CONFIG_HOME/bash/history"
source_if_exists "$XDG_CONFIG_HOME/bash/less"
source_if_exists "$XDG_CONFIG_HOME/bash/personal"

if [ -z "$NO_TMUX" ]; then
    if command -v fastfetch >/dev/null 2>&1; then
        echo
        fastfetch
        echo
    fi
    source_if_exists "$XDG_CONFIG_HOME/bash/tmux"
fi
