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


# terminal text tools
terminal_text_tools="figlet qrencode"
#terminal_text_tools=""


# terminal file browser
terminal_file_browser="nnn ranger vifm"
#terminal_file_browser=""


# file tools
file_tools="srm rsync gdisk"
#file_tools=""


# network tools
network_tools="wireshark-cli wireshark-qt mtr"
#network_tools=""


# internet tools
internet_tools="firefox-developer-edition w3m qutebrowser"
#internet_tools=""


# download utilities
download_utilities="aria2"
#download_utilities=""


# system monitoring
system_monitoring="glances ccze"
#system_monitoring=""


# virtual machines
virtual_machines="virtualbox virtualbox-host-modules-arch"
#virtual_machines=""


# image viewers
image_viewers="feh imv"
#image_viewers=""


# image editor
image_editors="imagemagick"
#image_editor=""


# pdf viewer
pdf_viewers="mupdf zathura-pdf-mupdf"
#pdf_viewers=""


# video tools
video_tools="youtube-dl mpv youtube-viewer"
#video_tools=""


# photo editing
#[TODO]
#photo_editing=""
#photo_editing=""


# photo management
#[TODO]
#photo_management=""
#photo_management=""


# office-tools
#office_tools="libreoffice-fresh libreoffice-fresh-nl"
office_tools=""


# mozilla firefox settings
function mozilla_firefox {
	[ -d ~/Downloads ] && rm -rf ~/Downloads
	[ -d ~/.mozilla ] && rm -rf ~/.mozilla
	git clone https://gitlab.com/cytopyge/ffxd_init ~/.mozilla
	cd ~/.mozilla
	git checkout -f addons
	cd ~
}

# make /usr rw
sudo mount -o remount,rw  /usr


# install app packages
yay -Sy $terminal_text_tools $terminal_file_browser $file_tools $network_tools $internet_tools $download_utilities $system_monitoring $virtual_machines $image_viewers $image_editors $pdf_viewers $video_tools $photo_editing $photo_management $office_tools


# function calls
mozilla_firefox


# make /usr ro
sudo mount -o remount,ro  /usr

clear
echo 'sh hajime/7logr.sh'
