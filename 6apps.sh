#!/bin/bash
#
##
###  _            _ _                                        
### | |__   __ _ (_|_)_ __ ___   ___    __ _ _ __  _ __  ___ 
### | '_ \ / _` || | | '_ ` _ \ / _ \  / _` | '_ \| '_ \/ __|
### | | | | (_| || | | | | | | |  __/ | (_| | |_) | |_) \__ \
### |_| |_|\__,_|/ |_|_| |_| |_|\___|  \__,_| .__/| .__/|___/6
###            |__/                         |_|   |_|        
###
###  _ _|_ _ ._    _  _  
### (_\/|_(_)|_)\/(_|(/_ 
###   /      |  /  _|                      
###
### hajime_apps
### cytopyge arch linux installation 'applications'
### epilogue of a five part installation series
###
### (c) 2019 cytopyge
###
## 
#

# make rw
sudo mount -o remount,rw  /usr

# video tools
yay -Syu --noconfirm youtube-dl mpv youtube-viewer

# terminal text tools
yay -S --noconfirm figlet

# terminal file browser
yay -S --noconfirm nnn ranger vifm

# file tools
yay -S --noconfirm srm rsync gdisk

# network tools
yay -S --noconfirm wireshark-cli wireshark-qt mtr

# download utility
yay -S --noconfirm aria2

# internet tools

## mozilla firefox
yay -S --noconfirm firefox-developer-edition
[ -d ~/Downloads ] && rm -rf ~/Downloads
[ -d ~/.mozilla ] && rm -rf ~/.mozilla
git clone https://gitlab.com/cytopyge/ffxd_init ~/.mozilla
cd ~/.mozilla
git checkout -f addons
cd ~

## w3m web browser
## also for ranger w3m image preview method
#[TODO]
yay -S --noconfirm w3m

# system monitoring
yay -S --noconfirm glances ccze

# virtual machines
yay -S --noconfirm virtualbox virtualbox-host-modules-arch

# qrcode
yay -S --noconfirm qrencode

#[TODO] 
# image viewer
yay -S --noconfirm feh imv

# image editor
yay -S --noconfirm imagemagick

# pdf viewer
yay -S --noconfirm mupdf zathura-pdf-mupdf

#[TODO]
# photo editing
# yay -S --noconfirm 

# libre-office
# yay -S --noconfirm libreoffice-fresh libreoffice-fresh-nl

# make ro
sudo mount -o remount,ro  /usr

clear
echo 'sh hajime/7logr.sh'
