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
### (c) 2019 - 2020 cytopyge
###
##
#


# user customizable variables
tmux_plugin_dir="$HOME/.config/tmux/plugins"


define_core_applications() {

	wayland="wlroots-git qt5-wayland"
		## qt5-wayland to prevent:
		## WARNING: Could not find the Qt platform plugin "wayland" in ""
		## when starting qutebrowser

	dwm="sway-git swaylock i3blocks waybar-git"

	shell="zsh"

	shell_additions="zsh-completions zsh-syntax-highlighting"

	terminal="termite-nocsd tmux"

	terminal_additions="rofi"

	manpages="man-db man-pages"

	password_security="pass ssss yubikey-manager"
		# pass-tomb bitwarden-cli pass-wl-clipboard

	encryption="veracrypt" # tomb

	secure_connections="wireguard-tools openvpn openvpn-update-systemd-resolved sshfs"

	fonts=""
		# "terminus-font ttf-inconsolata"

	display="brightnessctl"

	audio="pulseaudio pulseaudio-alsa pulsemixer alsa-utils"

	bluetooth="bluez bluez-utils pulseaudio-bluetooth"

}


define_additional_tools() {

	terminal_text_tools="emacs figlet qrencode zbar jq xxd-standalone"

	terminal_file_browser="vifm" #lf-git nnn

	file_tools="rsync gdisk simple-mtpfs tmsu"

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

}


create_core_applications_list(){

	core_applications=($wayland \
		$dwm \
		$shell \
		$shell_additions \
		$terminal \
		$terminal_additions \
		$manpages \
		$password_security \
		$encryption \
		$secure_connections \
		$fonts \
		$display \
		$audio \
		$bluetooth)

}


create_additional_tools_list() {

	additional_tools=($terminal_text_tools \
		$terminal_file_browser \
		$file_tools \
		$network_tools \
		$python_additions \
		$internet_tools \
		$feeds \
		$email \
		$contact_management \
		$time_management \
		$arithmatic \
		$accounting \
		$download_utilities \
		$system_monitoring \
		$virtualization \
		$image_capturing \
		$image_viewers \
		$image_editors \
		$pdf_viewers \
		$video_tools \
		$photo_editing \
		$photo_management \
		$vector_graphics_editing \
		$office_tools)

}


set_usr_rw() {

	## set /usr writeable
	sudo mount -o remount,rw  /usr

}


set_usr_ro() {

	# reset /usr read-only
	sudo mount -o remount,ro  /usr

}


install_core_applications() {

	## loop through core app packages
	## instead of one whole list entry in yay
	## this prevents that on error only one package is skipped

	for package in "${core_applications[@]}"; do

		yay -S --noconfirm "$package"

	done

}



install_additional_tools() {

	for package in "${additional_tools[@]}"; do

		yay -Sy --noconfirm "$package"

	done

}


loose_ends() {

	## fzf
	git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
	~/.fzf/install

	## tmux_plugin_manager
	git clone https://github.com/tmux-plugins/tpm $tmux_plugin_dir/tpm

	## execute dotfiles install script
	echo 'sh hajime/5dtcf.sh'

	## finishing
	sudo touch ~/hajime/4apps.done

}


define_core_applications
create_core_applications_list

define_additional_tools
create_additional_tools_list

set_usr_rw
install_core_applications
install_additional_tools
set_usr_ro

loose_ends
