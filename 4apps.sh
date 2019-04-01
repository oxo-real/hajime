#!/bin/bash
#
##
###  _            _ _                       _
### | |__   __ _ (_|_)_ __ ___   ___   _ __(_) ___ ___
### | '_ \ / _` || | | '_ ` _ \ / _ \ | '__| |/ __/ _ \
### | | | | (_| || | | | | | | |  __/ | |  | | (_|  __/
### |_| |_|\__,_|/ |_|_| |_| |_|\___| |_|  |_|\___\___|4
###            |__/
###
###  _ _|_ _ ._    _  _
### (_\/|_(_)|_)\/(_|(/_
###   /      |  /  _|
###
### hajime_rice
### cytopyge arch linux installation 'rice'
### fourth part of a series
###
### (c) 2019 cytopyge
###
##
#


clear


# user customizable variables


## core applications
## 'git' packages that need compiling are separated because of an error occuring in yay when combined
wayland=""
wayland_git="wlroots-git"

dwm="i3blocks"
dwm_git="sway-git swaylock-git slurp-git grim-git jq-git"

shell="zsh"
shell_git=""

shell_additions="zsh-completions zsh-syntax-highlighting"
shell_additions_git=""

terminal=""
terminal_git="termite-nocsd"

terminal_additions="rofi"
terminal_additions_git=""

password_security=""
password_security_git="bitwarden-cli"

encryption="veracrypt"
encryption_git=""

secure_connections="wireguard-tools openvpn"
secure_connections_git=""

fonts="terminus-font ttf-inconsolata"
fonts_git=""

display=""
display_git="brightnessctl"

audio="alsa-utils"
audio_git=""


# additional tools

terminal_text_tools="figlet qrencode"

terminal_file_browser="nnn ranger vifm"

file_tools="srm rsync gdisk"

network_tools="wireshark-cli wireshark-qt mtr"

internet_tools="firefox-developer-edition w3m qutebrowser"

download_utilities="aria2"

system_monitoring="glances ccze"

virtual_machines="virtualbox virtualbox-host-modules-arch"

image_viewers="feh imv"

image_editors="imagemagick"

pdf_viewers="mupdf zathura-pdf-mupdf"

video_tools="youtube-dl mpv youtube-viewer"

#[TODO]
photo_editing=""

#[TODO]
photo_management=""

office_tools=""
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


#install core applications git
yay -Sy --noconfirm \
	$wayland_git \
	$dwm_git \
	$shell_git \
	$shell_additions_git \
	$terminal_git \
	$terminal_additions_git \
	$password_security_git \
	$encryption_git \
	$secure_connections_git \
	$fonts_git \
	$display_git \
	$audio_git


#install additional tools
yay -Sy --noconfirm \
	$terminal_text_tools \
	$terminal_file_browser \
	$file_tools \
	$network_tools \
	$internet_tools \
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
echo 'sh hajime/5doti.sh'


# finishing
sudo touch hajime/4rice.done
