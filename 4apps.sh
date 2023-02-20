#!/usr/bin/env bash
#set -o errexit
set -o nounset
set -o pipefail
#
##
###  _            _ _
### | |__   __ _ (_|_)_ __ ___   ___    __ _ _ __  _ __  ___
### | '_ \ / _` || | | '_ ` _ \ / _ \  / _` | '_ \| '_ \/ __|
### | | | | (_| || | | | | | | |  __/ | (_| | |_) | |_) \__ \
### |_| |_|\__,_|/ |_|_| |_| |_|\___|  \__,_| .__/| .__/|___/4
###            |__/                         |_|   |_|
###  _    _
### (_)><(_)
###
### hajime_4apps
###
### fourth part of an intriguing series
### arch linux installation 'apps'
### copyright (c) 2019 - 2023  |  oxo
###
### GNU GPLv3 GENERAL PUBLIC LICENSE
### This file is part of hajime
###
### Hajime is free software: you can redistribute it and/or modify
### it under the terms of the GNU General Public License as published by
### the Free Software Foundation, either version 3 of the License, or
### (at your option) any later version.
###
### This program is distributed in the hope that it will be useful,
### but WITHOUT ANY WARRANTY; without even the implied warranty of
### MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
### GNU General Public License for more details.
###
### You should have received a copy of the GNU General Public License
### along with this program.  If not, see <https://www.gnu.org/licenses/>.
### https://www.gnu.org/licenses/gpl-3.0.txt
###
### @oxo@qoto.org
###
##
#

## dependencies
#	archlinux installation

## usage
#	sh hajime/4apps.sh

## example
#	none


# initial definitions

## script
script_name='4apps.sh'
developer='oxo'
license='gplv3'
initial_release='2019'

## hardcoded variables
# user customizable variables

## offline installation
offline=1
code_dir="/home/$(id -un)/dock/3"
repo_dir="/home/$(id -un)/dock/2"
repo_re="\/home\/$(id -un)\/dock\/2"
file_etc_pacman_conf='/etc/pacman.conf'
aur_dir="$repo_dir/aur"

#--------------------------------


define_core_applications()
{
    wayland="qt5-wayland wlroots wev xorg-xwayland ydotool"
    ## qt5-wayland to prevent:
    ## WARNING: Could not find the Qt platform plugin "wayland" in
    ## i.e. when starting qutebrowser

    dwm="i3blocks sway swaybg swayidle swaylock swaynagmode"
    # waybar

    shell="zsh"

    shell_additions="zsh-completions zsh-syntax-highlighting"

    terminal="alacritty tmux"
    #"termite-nocsd urxvt"

    terminal_additions="fzf fzf-tab-git mako"
    #"wofi rofi bemenu-wayland"

    manpages="man-db man-pages tldr"

    password_security="pass pass-otp yubikey-manager"
    #"pass-tomb bitwarden-cli pass-wl-clipboard"

    encryption="gnupg ssss"
    #"veracrypt tomb"

    security='opendoas'

    secure_connections="wireguard-tools protonvpn-cli-ng sshfs"

    filesystems="dosfstools ntfs-3g"

    fonts=""
    #"terminus-font ttf-inconsolata"

    display="brightnessctl"

    audio="sof-firmware pulseaudio pulseaudio-alsa pulsemixer alsa-utils"

    images="sxiv"
    #"fim ueberzug geekie"

    bluetooth="bluez bluez-utils pulseaudio-bluetooth"
}


define_additional_tools()
{
    build_tools='make'

    terminal_text_tools="emacs figlet qrencode zbar jq xxd-standalone vimball"

    terminal_file_browser="lf"
    #"vifm lf-git nnn"

    file_tools="rsync gdisk simple-mtpfs fd"
    #"tmsu trash-cli"

    debugging="strace"
    #"gdb valgrind"

    network_tools="mtr iftop bind-tools whois"
    #"wireshark-cli wireshark-qt"

    programming="go lisp lua perl python rustup"

    python_additions=""
    #"python-pip"

    internet_tools="firefox-developer-edition qutebrowser nyxt urlscan w3m"
    # lynx

    feeds="newsboat"

    email="neomutt msmtp isync notmuch protonmail-bridge"

    time_management=""
    #"calcurse task"

    arithmatic="bc qalculate-qt"

    mathematics=""
    #"gnu-plot"

    accounting=""
    #"ledger hledger"

    download_utilities="aria2 transmission-cli transmission-remote-cli-git"

    system_info="lshw"

    system_monitoring="glances viddy"
    # ccze

    virtualization="qemu qemu-arch-extra virt-manager bridge-utils dnsmasq vde2 openbsd-netcat"
    #"ovmf ebtables virt-viewer virtualbox virtualbox-host-modules-arch docker"

    image_capturing="grim slurp"

    image_viewers="feh imv"

    image_editors="imagemagick"

    pdf_viewers="mupdf zathura-pdf-mupdf"

    video_tools="youtube-dl mpv pipe-viewer"
    #"straw-viewer youtube-viewer"

    photo_editing=""
    #"gimp"

    photo_management=""
    #"digikam darktable"

    vector_graphics_editing=""
    #"inkscape"

    office_tools=""
    #"libreoffice-fresh"

    cad=""
    #"freecad"
}


mount_repo()
{
    repo_lbl='REPO'
    repo_dev=$(lsblk -o label,path | grep "$repo_lbl" | awk '{print $2}')

    [[ -d $repo_dir ]] || mkdir -p "$repo_dir"

    mountpoint -q $repo_dir
    [[ $? -eq 0 ]] || sudo mount "$repo_dev" "$repo_dir"
}


get_offline_repo()
{
    case $offline in
	1)
	    mount_repo
	    ;;
    esac
}


mount_code()
{
    code_lbl='CODE'
    code_dev=$(lsblk -o label,path | grep "$code_lbl" | awk '{print $2}')

    [[ -d $code_dir ]] || mkdir -p "$code_dir"

    mountpoint -q $code_dir
    [[ $? -eq 0 ]] || sudo mount "$code_dev" "$code_dir"
}


get_offline_code()
{
    case $offline in
	1)
	    mount_code
	    ;;
    esac
}


aur_install()
{
    ## install all aur packages
    for package in $(ls $aur_dir); do

	cd $aur_dir/$package
	makepkg -i --noconfirm --needed
	cd ..

    done

    ## generate a development package database
    yay -Y --gendb

    ## update local repo
    yay -Syy
}


create_core_applications_list()
{
    core_applications=(\
		       $wayland \
			   $dwm \
			   $shell \
			   $shell_additions \
			   $terminal \
			   $terminal_additions \
			   $manpages \
			   $password_security \
			   $encryption \
			   $security \
			   $secure_connections \
			   $filesystems \
			   $fonts \
			   $display \
			   $audio \
			   $images \
			   $bluetooth\
	)
}


create_additional_tools_list()
{
    additional_tools=(\
		      $build_tools \
			  $terminal_text_tools \
			  $terminal_file_browser \
			  $file_tools \
			  $debugging \
			  $network_tools \
			  $programming \
			  $python_additions \
			  $internet_tools \
			  $feeds \
			  $email \
			  $time_management \
			  $arithmatic \
			  $mathematics \
			  $accounting \
			  $download_utilities \
			  $system_info \
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
			  $office_tools\
			  $cad\
	)
}


set_usr_rw()
{
    ## set /usr writeable
    sudo mount -o remount,rw  /usr
}


set_usr_ro()
{
    # reset /usr read-only
    sudo mount -o remount,ro  /usr
}


install_core_applications()
{
    ## loop through core app packages
    ## instead of one whole list entry in yay
    ## this prevents that on error only one package is skipped
    #local packages=$(echo "${core_applications[*]}")
    #sudo pacman -S --noconfirm --needed $packages
    for pkg_ca in "${core_applications[@]}"; do

	yay -S --noconfirm --needed "$pkg_ca"
	#sudo pacman -S --noconfirm --needed "$pkg_ca"

    done
}



install_additional_tools()
{
    ## loop through core app packages
    ## instead of one whole list entry in yay
    ## this prevents that on error only one package is skipped
    #local packages=$(echo "${additional_tools[*]}")
    #sudo pacman -S --noconfirm --needed $packages
    for pkg_at in "${additional_tools[@]}"; do

	yay -S --noconfirm --needed "$pkg_at"
	#sudo pacman -Sy --noconfirm --needed "$pkg_at"

    done
}


loose_ends()
{
    #[TODO]remove candidate
    ## tmux_plugin_manager
    #tmux_plugin_dir="$HOME/.config/tmux/plugins"
    #git clone https://github.com/tmux-plugins/tpm $tmux_plugin_dir/tpm

    #[TODO]remove candidate
    ## create w3mimgdisplay symlink
    ## w3mimgdisplay is not in /usr/bin by default as of 20210114
    ## alternative is to add /usr/lib/w3m to $PATH
    #sudo ln -s /usr/lib/w3m/w3mimgdisplay /usr/bin/w3mimgdisplay

    ## recommend human to execute dotfiles install script
    echo 'sh hajime/5dtcf.sh'

    ## finishing
    sudo touch $HOME/hajime/4apps.done
}


main() {
    define_core_applications
    create_core_applications_list

    define_additional_tools
    create_additional_tools_list

    set_usr_rw
    get_offline_repo
    get_offline_code
    aur_install
    install_core_applications
    install_additional_tools
    loose_ends
    set_usr_ro
}

main
