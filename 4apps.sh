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
tmux_plugin_dir="$HOME/.config/tmux/plugins"

## core applications

wayland="wlroots-git"

dwm="sway-git swaylock-git i3blocks grim-git"

shell="zsh"

shell_additions="zsh-completions zsh-syntax-highlighting"

terminal="termite-nocsd tmux"

terminal_additions="rofi"

password_security="pass-wl-clipboard bitwarden-cli"

encryption="veracrypt"

secure_connections="wireguard-tools openvpn"

fonts="terminus-font ttf-inconsolata"

display="brightnessctl"

audio="pulseaudio alsa-utils"

bluetooth="bluez bluez-utils pulseaudio-bluetooth"


# additional tools

terminal_text_tools="emacs figlet qrencode jq xxd-standalone"

terminal_file_browser="nnn vifm lf-git"

file_tools="srm rsync gdisk"

network_tools="wireshark-cli wireshark-qt mtr iftop"

internet_tools="firefox-developer-edition qutebrowser urlscan"

feeds="newsboat"

email="neomutt msmtp isync notmuch protonmail-bridge"

contact_management="abook"

time_management="calcurse"

download_utilities="aria2 transmission-cli transmission-remote-cli-git"

system_monitoring="glances ccze"

virtual_machines="" #"virtualbox virtualbox-host-modules-arch"

image_viewers="feh imv"

image_editors="imagemagick"

pdf_viewers="mupdf zathura-pdf-mupdf"

video_tools="youtube-dl mpv youtube-viewer"

weather="wttr metar"


#[TODO]
#photo_editing="gimp"

#[TODO]
## which one prefers?
#photo_management="digikam darktable"

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
	$audio \
	$bluetooth


# install additional tools
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
	$office_tools \
	$weather


# loose ends

## fzf
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install


## tmux_plugin_manager
git clone https://github.com/tmux-plugins/tpm $tmux_plugin_dir/tpm


# reset /usr read-only
sudo mount -o remount,ro  /usr


# execute dotfiles install script
echo 'sh hajime/5dtcf.sh'


# finishing
sudo touch ~/hajime/4apps.done
