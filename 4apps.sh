#!/bin/bash
#
##
###
###  _            _ _
### | |__   __ _ (_|_)_ __ ___   ___    __ _ _ __  _ __  ___
### | '_ \ / _` || | | '_ ` _ \ / _ \  / _` | '_ \| '_ \/ __|
### | | | | (_| || | | | | | | |  __/ | (_| | |_) | |_) \__ \
### |_| |_|\__,_|/ |_|_| |_| |_|\___|  \__,_| .__/| .__/|___/4
###            |__/                         |_|   |_|
###
###  _ _|_ _ ._    _  _
### (_\/|_(_)|_)\/(_|(/_
###   /      |  /  _|
###
### hajime_apps
### cytopyge arch linux installation 'apps'
### fourth part of an intriguing series
###
### (c) 2019 cytopyge
###
##
#


clear


# user customizable variables

## core applications

wayland="wlroots-git"

dwm="sway-git swaylock-git i3blocks xtitle-git slurp-git grim-git jq-git"

shell="zsh"

shell_additions="zsh-completions zsh-syntax-highlighting"

terminal="termite-nocsd tmux"

terminal_additions="rofi"

password_security="bitwarden-cli"

encryption="veracrypt"

secure_connections="wireguard-tools openvpn"

fonts="terminus-font ttf-inconsolata"

display="brightnessctl"

audio="alsa-utils"


# additional tools

terminal_text_tools="figlet qrencode"

terminal_file_browser="nnn vifm lf"

file_tools="srm rsync gdisk"

network_tools="wireshark-cli wireshark-qt mtr iftop"

internet_tools="firefox-developer-edition qutebrowser urlscan"

feeds="newsboat"

email="neomutt msmtp isync notmuch protonmail-bridge"

contact_management="abook"

time_management="calcurse"

download_utilities="aria2 transmission"

system_monitoring="glances ccze"

virtual_machines="virtualbox virtualbox-host-modules-arch"

image_viewers="feh imv"

image_editors="imagemagick"

pdf_viewers="mupdf zathura-pdf-mupdf"

video_tools="youtube-dl mpv youtube-viewer"

#[TODO]
#photo_editing=""

#[TODO]
#photo_management=""

#office_tools=""
#office_tools="libreoffice-fresh libreoffice-fresh-nl"


# set /usr writeable
sudo mount -o remount,rw  /usr


# install core applications
yay -Sy --noconfirm \
	$wayland \
	$dwm \
	$shell \
	$shell_additions \
	$terminal \
	$terminal_additions \
	$password_security \
	$encryption \
	$secure_connections \
	$fonts \
	$display \
	$audio

## fzf
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install


#install additional tools
yay -Sy --noconfirm \
	$terminal_text_tools \
	$terminal_file_browser \
	$file_tools \
	$network_tools \
	$internet_tools \
	$feeds \
	$email \
	$contact_management \
	$time_management \
	$download_utilities \
	$system_monitoring \
	$virtual_machines \
	$image_viewers \
	$image_editors \
	$pdf_viewers \
	$video_tools \
	$photo_editing \
	$photo_management \
	$office_tools


#[TODO] jq termite-nocsd bitwarden-cli brightnessctl gdisk
yay -Sy --noconfirm jq termite-nocsd bitwarden-cli brightnessctl gdisk


# X11
# https://wiki.archlinux.org/index.php/Libinput#Configuration
# https://wiki.archlinux.org/index.php/Libinput#Via_xinput
# xorg-xrdb for loading .Xresources
# xorg-xinput to alter libinput settings (mouse, keyboard)
#yay -S --noconfirm xorg-xrdb xorg-xinput xorg-xinit xterm #xorg


# video drivers (X11)
#lspci | grep VGA
## fallback driver
#yay -S --noconfirm xf86-video-vesa
## open source
### lspci | grep VGA
### yay -Ss xf86-video | less
### find and install proper drivers
## nvidia
### yay -S nvidia lib32-nvidia-utils
## ati
### yay -S linux-headers caltalist-dkms catalist-utils lib32-catalist-utils
## advice on xserver problems
## yay -S xf86-video-intel


# shell of choice: ZSH
#yay -S --noconfirm zsh


# desktop window manager
#yay -S --noconfirm sway-git swaylock-git i3blocks


# terminal emulator of choice

## wayland native termite alternative
## no client side decorations
#yay -S --noconfirm termite-nocsd

## under X11
# get .Xresources from archive
#yay -S --noconfirm rxvt-unicode


# essential terminal tools

## rofi
#yay -S --noconfirm rofi


# display brightness control
#yay -S --noconfirm brightnessctl


# sound
#yay -S --noconfirm alsa-utils #pulse-audio


# fonts

## monospace
## terminus-font
#yay -S --noconfirm terminus-font
### Xresources: 'URxvt.font: xft:xos4 Terminus:size=12'
## install terminus-font
#yay -Ql terminus-font
## set terminus-font
#setfont ter-v14n

## ttf/otf fonts
## inconsolata
#yay -S --noconfirm ttf-inconsolata
## Xresources: 'URxvt.font: xft:Inconsolata:size=12'
#yay -S --noconfirm terminus-font-ttf
## Xresources: 'URxvt.font: xft:Terminus (TTF):size=12:style=Medium'

## other ttf/otf font options
#yay -S --noconfirm ttf-linux-libertine


# reset /usr read-only
sudo mount -o remount,ro  /usr


# execute dotfiles install script
echo 'sh hajime/5dtcf.sh'


# finishing
sudo touch hajime/4apps.done
