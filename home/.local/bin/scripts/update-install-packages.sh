#!/bin/sh

pacman -Qneq |
    sort -i \
        >~/Projects/dotfiles/install/pacman.txt
pacman -Qmeq |
    grep -v '^paru-debug$' |
    sort -i \
        >~/Projects/dotfiles/install/aur.txt
uv tool list --show-extras |
    grep -E '^[a-z]' |
    sort -i |
    sed -E 's/ v[^ ]+//; s/ \[extras: ([^]]+)\]/[\1]/; s/, +/,/g; s#^gallery-dl\[extra\]#git+https://github.com/NecRaul/gallery-dl[extra]#' \
        >~/Projects/dotfiles/install/uv.txt
npm list -g --depth=0 |
    grep -E '^[├└]' |
    sed -E 's/^[├└]── //; s/@[^@]+$//; /^tree-sitter$/d' |
    sort -i \
        >~/Projects/dotfiles/install/npm.txt
cargo install --list |
    grep -E '^[a-zA-Z0-9_-]+ v[0-9]' |
    sed -E 's/ v.*//' |
    sort -i \
        >~/Projects/dotfiles/install/cargo.txt
for bin in "$(go env GOBIN)/"*; do
    go version -m "$bin" 2>/dev/null
done |
    grep -E '^\s+path\s' |
    sed -E 's/^[[:space:]]*path[[:space:]]+(.+)$/\1@latest/' |
    sort -i \
        >~/Projects/dotfiles/install/go.txt
