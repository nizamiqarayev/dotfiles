# dotfiles

My dotfiles and post-install script for Arch Linux.

## Installation

```sh
cd /path/to/where/you/keep/your/git/repositories
git clone --recursive git@github.com:nizamiqarayev/dotfiles.git
cd dotfiles
./install.sh
source ~/.bashrc
```

## After reboot

I excluded copying the sddm configuration, because it would cause a loop on my end. After rebooting your computer and logging in, to set the sddm settings run the command below (from this repo's root).

```sh
sudo cp -f $(pwd)/etc/sddm.conf /etc/sddm.conf
```

I would also recommend uninstalling and reinstalling `zathura-pdf-mupdf` because `--noconfirm` flag automatically picks `afr` as the default `tessdata` (OCR data) language.

```sh
sudo pacman -Rncs zathura-pdf-mupdf
sudo pacman -S zathura-pdf-mupdf
# English is 30
```
