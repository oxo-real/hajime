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

dwm="sway-git swaylock i3blocks"

shell="zsh"

shell_additions="zsh-completions zsh-syntax-highlighting"

terminal="termite-nocsd tmux"

terminal_additions="rofi"

manpages="man-db man-pages"

password_security="pass bitwarden-cli" #pass-wl-clipboard

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

network_tools="wireshark-cli wireshark-qt mtr iftop bind-tools whois"

python_additions="python-pip"

internet_tools="firefox-developer-edition qutebrowser urlscan"

feeds="newsboat"

email="neomutt msmtp isync notmuch protonmail-bridge"

contact_management="abook"

time_management="calcurse"

arithmatic="bc"

accounting="ledger"

download_utilities="aria2 transmission-cli transmission-remote-cli-git"

system_monitoring="glances ccze"

virtualization="docker" #"virtualbox virtualbox-host-modules-arch"

image_capturing="grim-git slurp"

image_viewers="feh imv"

image_editors="imagemagick"

pdf_viewers="mupdf zathura-pdf-mupdf"

video_tools="youtube-dl mpv youtube-viewer"

photo_editing="" #"gimp"

photo_management="" #"digikam darktable"

vector_graphics_editing="" #"inkscape"

office_tools="" #"libreoffice-fresh libreoffice-fresh-nl"


# set /usr writeable
sudo mount -o remount,rw  /usr


# install core applications
core_applications=($wayland $dwm $shell $shell_additions $terminal $terminal_additions $manpages $password_security $encryption $secure_connections $fonts $display $audio $bluetooth)

for package in "${core_applications[@]}"; do
	yay -S --noconfirm "$package"
done


# install additional tools
additional_tools=($terminal_text_tools $terminal_file_browser $file_tools $network_tools $python_additions $internet_tools $feeds $email $contact_management $time_management $arithmatic $accounting $download_utilities $system_monitoring $virtualization $image_capturing $image_viewers $image_editors $pdf_viewers $video_tools $photo_editing $photo_management $vector_graphics_editing $office_tools)

for package in "${additional_tools[@]}"; do
	yay -Sy --noconfirm "$package"
done


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
