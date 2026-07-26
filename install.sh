#!/bin/bash

setup_xdg_environment() {
    # XDG Setup
    export XDG_CACHE_HOME="$HOME/.cache"
    export XDG_CONFIG_HOME="$HOME/.config"
    export XDG_DATA_HOME="$HOME/.local/share"
    export XDG_STATE_HOME="$HOME/.local/state"

    # XDG_CACHE_HOME
    export NUGET_PACKAGES="$XDG_CACHE_HOME/NuGetPackages"

    # XDG_CONFIG_HOME
    export OMNISHARPHOME="$XDG_CONFIG_HOME/omnisharp"

    # XDG_DATA_HOME
    export DOTNET_CLI_HOME="$XDG_DATA_HOME"/dotnet
    export GNUPGHOME="$XDG_DATA_HOME/gnupg"
    export GRADLE_USER_HOME="$XDG_DATA_HOME/gradle"
}

create_folders() {
    mkdir -p "$HOME/.cache/wallpapers"
    mkdir -p "$HOME/.config"
    mkdir -p "$HOME/.local/bin"
    mkdir -p "$HOME/.local/share/applications"
    mkdir -p "$HOME/.local/share/dwm"
    mkdir -p "$HOME/Documents/Notes"
    mkdir -p "$HOME/Downloads"
    mkdir -p "$HOME/Music"
    mkdir -p "$HOME/Pictures/mpv"
    mkdir -p "$HOME/Pictures/Screenshots"
    mkdir -p "$HOME/Pictures/Wallpapers"
    mkdir -p "$HOME/Videos/mpv"
    mkdir -p "$HOME/Videos/Recordings"
    mkdir -p "$HOME/Games"
    mkdir -p "$HOME/Projects"
    mkdir -p "$HOME/Torrents"
    sudo mkdir -p /etc/modprobe.d
    sudo mkdir -p /etc/profile.d
    sudo mkdir -p /root/.config
    sudo mkdir -p /usr/share/xsessions
}

no_password_sudoers() {
    # This is unnecessary if you can already use sudo without using password and should be commented out
    sudo sed -i "/^root\sALL=(ALL:ALL)\sALL/a $USER ALL=(ALL) NOPASSWD: ALL" /etc/sudoers
    echo "==================================================="
    echo "Enabled $USER to use sudo without having to enter password."
}

enable_pacman_color() {
    sudo sed -i 's/^#Color/Color/' /etc/pacman.conf
    echo "==================================================="
    echo "Enabled colors on pacman and AUR helpers like paru and yay."
}

update_upgrade_packages() {
    echo "==================================================="
    echo "Updating and upgrading packages."
    echo "==================================================="
    sudo pacman -Syu --noconfirm
    echo "==================================================="
    echo "Updated and upgraded packages."
}

install_pacman_packages() {
    echo "==================================================="
    echo "Installing pacman packages."
    echo "==================================================="
    # Note: pacman -Qneq gives explicitly installed pacman packages
    while IFS= read -r package || [ -n "$package" ]; do
        if ! pacman -Qq "$package" &>/dev/null; then
            ((attempted_packages++))
            if sudo pacman -S --noconfirm --needed "$package"; then
                ((installed_packages++))
            else
                no_install_pacman_packages+=("$package")
            fi
        fi
    done <"install/pacman.txt"
    echo "==================================================="
    echo "Finished installing pacman packages."
    echo "$installed_packages/$attempted_packages installed."
}

install_aur_packages() {
    echo "==================================================="
    echo "Installing AUR packages."
    echo "==================================================="
    # Note: pacman -Qmeq gives explicitly installed AUR packages
    while IFS= read -r package || [ -n "$package" ]; do
        if ! pacman -Qm "$package" &>/dev/null; then
            ((attempted_packages++))
            if paru -S --noconfirm --needed "$package"; then
                ((installed_packages++))
            else
                no_install_aur_packages+=("$package")
            fi
        fi
    done <"install/aur.txt"
    echo "==================================================="
    echo "Finished installing AUR packages."
    echo "$installed_packages/$attempted_packages installed."
}

install_aur_packages_2_electric_boogaloo() {
    echo "==================================================="
    echo "Install packages that couldn't be installed using pacman."
    echo "==================================================="
    if [ ${#no_install_pacman_packages[@]} -gt 0 ]; then
        for package in "${no_install_pacman_packages[@]}"; do
            if ! pacman -Qq "$package" &>/dev/null; then
                ((attempted_packages++))
                if paru -S --noconfirm --needed "$package"; then
                    ((installed_packages++))
                else
                    no_install_aur_packages+=("$package")
                fi
            fi
        done
    fi
    echo "==================================================="
    echo "Finished trying to install packages that couldn't be installed using pacman."
    echo "$installed_packages/$attempted_packages installed."
}

install_uv_packages() {
    echo "==================================================="
    echo "Installing uv packages."
    echo "==================================================="
    # Note: Command below gives installed uv packages.
    # uv tool list --show-extras |
    #   command grep -E '^[a-z]' |
    #   command sed -E 's/ v[^ ]+//; s/ \[extras: ([^]]+)\]/[\1]/; s/, +/,/g'
    while IFS= read -r package || [ -n "$package" ]; do
        [ -z "$package" ] && continue
        ((attempted_packages++))
        if uv tool install "$package"; then
            ((installed_packages++))
        else
            no_install_uv_packages+=("$package")
        fi
    done <"install/uv.txt"
    echo "==================================================="
    echo "Finished installing uv packages."
    echo "$installed_packages/$attempted_packages installed."
}

install_pnpm_packages() {
    echo "==================================================="
    echo "Installing pnpm packages."
    echo "==================================================="
    # Note: Command below gives installed pnpm packages.
    # pnpm list -g --depth=0 |
    #   command grep -E '^[├└]' |
    #   command sed -E 's/^[├└]── //; s/@[^@]+$//'
    export NPM_CONFIG_PREFIX="$XDG_DATA_HOME/npm"
    export PNPM_HOME="$XDG_DATA_HOME/pnpm"
    export PATH="$NPM_CONFIG_PREFIX/bin:$PATH"
    export PATH="$PNPM_HOME/bin:$PATH"
    npm install -g pnpm
    while IFS= read -r package || [ -n "$package" ]; do
        [ -z "$package" ] && continue
        ((attempted_packages++))
        if pnpm install -g "$package"; then
            ((installed_packages++))
        else
            no_install_pnpm_packages+=("$package")
        fi
    done <"install/pnpm.txt"
    echo "==================================================="
    echo "Finished installing pnpm packages."
    echo "$installed_packages/$attempted_packages installed."
}

install_cargo_packages() {
    echo "==================================================="
    echo "Installing cargo packages."
    echo "==================================================="
    # Note: Command below gives installed cargo packages.
    # cargo install --list |
    #   command grep -E '^[a-zA-Z0-9_-]+ v[0-9]' |
    #   command sed -E 's/ v.*//'
    export RUSTUP_HOME="$XDG_DATA_HOME/rustup"
    export CARGO_HOME="$XDG_DATA_HOME/cargo"
    export PATH="$CARGO_HOME/bin:$PATH"
    rustup default stable
    cargo install cargo-binstall
    while IFS= read -r package || [ -n "$package" ]; do
        [ -z "$package" ] && continue
        ((attempted_packages++))
        if [ "$package" = "wallpapers" ]; then
            if cargo install --git https://github.com/awused/wallpapers --locked --no-default-features --features x11; then
                ((installed_packages++))
            else
                no_install_cargo_packages+=("$package")
            fi
        elif cargo binstall "$package"; then
            ((installed_packages++))
        else
            no_install_cargo_packages+=("$package")
        fi
    done <"install/cargo.txt"
    echo "==================================================="
    echo "Finished installing cargo packages."
    echo "$installed_packages/$attempted_packages installed."
}

install_go_packages() {
    echo "==================================================="
    echo "Installing go packages."
    echo "==================================================="
    # Note: Command below gives installed go packages.
    # for bin in "$(go env GOBIN)/"*; do
    #   go version -m "$bin" 2>/dev/null
    # done |
    #   command grep -E '^\s+path\s' |
    #   command sed -E 's/^[[:space:]]*path[[:space:]]+(.+)$/\1@latest/'
    export GOPATH="$XDG_DATA_HOME/go"
    export GOBIN="$XDG_DATA_HOME/go/bin"
    export PATH="$GOBIN:$PATH"
    while IFS= read -r package || [ -n "$package" ]; do
        [ -z "$package" ] && continue
        ((attempted_packages++))
        if go install "$package"; then
            ((installed_packages++))
        else
            no_install_go_packages+=("$package")
        fi
    done <"install/go.txt"
    echo "==================================================="
    echo "Finished installing go packages."
    echo "$installed_packages/$attempted_packages installed."
}

clear_pacman_cache() {
    echo "==================================================="
    echo "Clearing pacman cache."
    echo "==================================================="
    sudo pacman -Scc --noconfirm
    paccache -rk0
    echo "==================================================="
    echo "Cleared pacman cache."
}

clear_aur_cache() {
    echo "==================================================="
    echo "Clearing AUR cache."
    echo "==================================================="
    paru -Scc --noconfirm
    paccache -rk0
    echo "==================================================="
    echo "Cleared AUR cache."
}

clear_uv_cache() {
    echo "==================================================="
    echo "Clearing uv cache."
    echo "==================================================="
    uv cache clean
    uv cache prune
    echo "==================================================="
    echo "Cleared uv cache."
}

clear_pnpm_cache() {
    echo "==================================================="
    echo "Clearing pnpm cache."
    echo "==================================================="
    export PNPM_HOME="$XDG_DATA_HOME/pnpm"
    export PATH="$PNPM_HOME/bin:$PATH"
    pnpm cache delete
    pnpm store prune
    echo "==================================================="
    echo "Cleared pnpm cache."
}

clear_cargo_cache() {
    echo "==================================================="
    echo "Clearing cargo cache."
    echo "==================================================="
    export RUSTUP_HOME="$XDG_DATA_HOME/rustup"
    export CARGO_HOME="$XDG_DATA_HOME/cargo"
    export PATH="$CARGO_HOME/bin:$PATH"
    cargo cache --autoclean
    echo "==================================================="
    echo "Cleared cargo cache."
}

clear_go_cache() {
    echo "==================================================="
    echo "Clearing go cache."
    echo "==================================================="
    export GOPATH="$XDG_DATA_HOME/go"
    export GOBIN="$XDG_DATA_HOME/go/bin"
    export PATH="$GOBIN:$PATH"
    go clean -cache -modcache
    echo "==================================================="
    echo "Cleared go cache."
}

removing_unnecessary_dependencies() {
    echo "==================================================="
    echo "Removing unnecessary dependencies."
    echo "==================================================="
    # shellcheck disable=SC2046
    sudo pacman -Rncs $(pacman -Qdtq) --noconfirm
    # shellcheck disable=SC2046
    paru -Rncs $(paru -Qdtq) --noconfirm
    echo "==================================================="
    echo "Removed unnecessary dependencies."
}

install_paru() {
    echo "==================================================="
    echo "Installing paru."
    echo "==================================================="
    if ! pacman -Qq paru &>/dev/null; then
        git clone https://aur.archlinux.org/paru.git
        cd paru || exit
        makepkg -si --noconfirm --needed
        cd ..
        rm -rf paru
        echo "==================================================="
        echo "Installed paru."
    else
        echo "paru is already installed."
    fi
}

install_blesh() {
    echo "==================================================="
    echo "Installing ble.sh."
    echo "==================================================="
    git clone --recursive --depth 1 --shallow-submodules https://github.com/akinomyoga/ble.sh.git
    make -C "$(pwd)/ble.sh" install PREFIX="$HOME/.local"
    rm -rf "$(pwd)/ble.sh"
    echo "==================================================="
    echo "Installed ble.sh."
}

create_symlinks() {
    echo "==================================================="
    echo "Creating symlinks."

    # / #
    [ -f /etc/sddm.conf ] && sudo cp -v /etc/sddm.conf /etc/sddm.conf.bak
    sudo cp -rfv "$(pwd)"/{etc,usr} /
    [ -f /etc/sddm.conf.bak ] && sudo mv -v /etc/sddm.conf.bak /etc/sddm.conf
    # # #

    # root home #
    for item in "$(pwd)/root/".*; do
        item_name="$(basename "$item")"
        [ "$item_name" = "." ] && continue
        [ "$item_name" = ".." ] && continue
        [ "$item_name" = ".config" ] && continue
        [ "$item_name" = ".local" ] && continue
        sudo ln -sfnv "$item" "/root/$item_name"
    done
    # # # # # # # #

    # root config #
    for item in "$(pwd)/root/.config/"*; do
        item_name="$(basename "$item")"
        sudo ln -sfnv "$item" "/root/.config/$item_name"
    done
    # # # # # # # #

    # ~ #
    for item in "$(pwd)/home/".*; do
        item_name="$(basename "$item")"
        [ "$item_name" = "." ] && continue
        [ "$item_name" = ".." ] && continue
        [ "$item_name" = ".config" ] && continue
        [ "$item_name" = ".local" ] && continue
        ln -sfnv "$item" "$HOME/$item_name"
    done
    # # #

    # config #
    for item in "$(pwd)/home/.config/"*; do
        item_name="$(basename "$item")"
        [ "$item_name" = "systemd" ] && continue
        ln -sfnv "$item" "$HOME/.config/$item_name"
    done
    mkdir -p "$HOME/.config/systemd/user"
    ln -sfnv "$(pwd)/home/.config/systemd/user/"* "$HOME/.config/systemd/user"
    # # # # # #

    # bin #
    for item in "$(pwd)/home/.local/bin/"*; do
        item_name="$(basename "$item")"
        [ "$item_name" = "pyupload" ] && continue
        mkdir -p "$HOME/.local/bin/$item_name"
        ln -sfnv "$item/"* "$HOME/.local/bin/$item_name"
    done
    mkdir -p "$HOME/.local/bin/pyupload-devel"
    ln -sfnv "$(pwd)/home/.local/bin/pyupload/"* "$HOME/.local/bin/pyupload-devel"
    # # # #

    # share #
    for item in "$(pwd)/home/.local/share/applications/"*; do
        item_name="$(basename "$item")"
        ln -sfnv "$item" "$HOME/.local/share/applications/$item_name"
    done
    for item in "$(pwd)/home/.local/share/dwm/"*; do
        item_name="$(basename "$item")"
        ln -sfnv "$item" "$HOME/.local/share/dwm/$item_name"
    done
    ln -sfnv "$(pwd)/home/.local/share/kio" "$HOME/.local/share/kio"
    [ -e "$HOME/.local/share/bg" ] || ln -sfnv "$(pwd)/home/.local/share/bg" "$HOME/.local/share/bg"
    # # # # #

    echo "==================================================="
    echo "Created symlinks."
}

install_zathura_pywal() {
    echo "==================================================="
    echo "Installing zathura-pywal."

    sudo make install -C "$HOME/.local/bin/zathura-pywal"
    zathura-pywal -a 0.8

    echo "==================================================="
    echo "Installed zathura-pywal."
}

install_grub_theme() {
    echo "==================================================="
    echo "Installing GRUB theme."

    sudo bash "$(pwd)/home/.local/bin/kuroneko-themes/install.sh"

    echo "==================================================="
    echo "Installed GRUB theme."
}

enable_services() {
    echo "==================================================="
    echo "Enabling systemd services."

    sudo systemctl enable sddm.service
    for item in "$(pwd)/home/.config/systemd/user/"*; do
        item_name="$(basename "$item")"
        systemctl --user enable "$item_name"
    done

    echo "==================================================="
    echo "Enabled systemd services."
}

no_install_arrays() {
    # Array to hold pacman, AUR, uv, pnpm, cargo, and go packages that couldn't be installed
    declare -a no_install_pacman_packages=()
    declare -a no_install_aur_packages=()
    declare -a no_install_uv_packages=()
    declare -a no_install_pnpm_packages=()
    declare -a no_install_cargo_packages=()
    declare -a no_install_go_packages=()
}

reset_package_count() {
    declare -gi installed_packages=0
    declare -gi attempted_packages=0
}

no_install_packages_to_txt() {
    mkdir -p no_install
    printf "%s\n" "${no_install_pacman_packages[@]}" >no_install/pacman.txt
    printf "%s\n" "${no_install_aur_packages[@]}" >no_install/aur.txt
    printf "%s\n" "${no_install_uv_packages[@]}" >no_install/uv.txt
    printf "%s\n" "${no_install_pnpm_packages[@]}" >no_install/pnpm.txt
    printf "%s\n" "${no_install_cargo_packages[@]}" >no_install/cargo.txt
    printf "%s\n" "${no_install_go_packages[@]}" >no_install/go.txt
    echo "==================================================="
    echo "Script has finished running. Packages that couldn't be installed were written into text files in the no_install folder."
    echo "==================================================="
}

install_all_packages() {
    setup_xdg_environment

    no_install_arrays

    reset_package_count
    install_pacman_packages
    clear_pacman_cache

    install_paru

    reset_package_count
    install_aur_packages

    reset_package_count
    install_aur_packages_2_electric_boogaloo
    clear_aur_cache

    removing_unnecessary_dependencies

    reset_package_count
    install_uv_packages
    clear_uv_cache

    reset_package_count
    install_pnpm_packages
    clear_pnpm_cache

    reset_package_count
    install_cargo_packages
    clear_cargo_cache

    reset_package_count
    install_go_packages
    clear_go_cache

    no_install_packages_to_txt
}

main() {
    setup_xdg_environment
    create_folders

    no_password_sudoers
    enable_pacman_color

    update_upgrade_packages

    no_install_arrays

    reset_package_count
    install_pacman_packages
    clear_pacman_cache

    install_paru

    reset_package_count
    install_aur_packages

    reset_package_count
    install_aur_packages_2_electric_boogaloo
    clear_aur_cache
    removing_unnecessary_dependencies

    reset_package_count
    install_uv_packages
    clear_uv_cache

    reset_package_count
    install_pnpm_packages
    clear_pnpm_cache

    reset_package_count
    install_cargo_packages
    clear_cargo_cache

    reset_package_count
    install_go_packages
    clear_go_cache

    create_symlinks

    install_zathura_pywal

    install_blesh

    install_grub_theme

    enable_services

    no_install_packages_to_txt
}

case "${1:-all}" in
all)
    main
    ;;
packages)
    update_upgrade_packages
    install_all_packages
    ;;
links)
    create_symlinks
    ;;
services)
    enable_services
    ;;
*)
    if declare -F "$1" >/dev/null; then
        "$@"
    else
        echo "Usage: $0 [all|packages|links|services|function]"
        exit 1
    fi
    ;;
esac
