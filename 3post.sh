#! /usr/bin/env sh

###  _            _ _                                  _
### | |__   __ _ (_|_)_ __ ___   ___   _ __   ___  ___| |_
### | '_ \ / _` || | | '_ ` _ \ / _ \ | '_ \ / _ \/ __| __|
### | | | | (_| || | | | | | | |  __/ | |_) | (_) \__ \ |_
### |_| |_|\__,_|/ |_|_| |_| |_|\___| | .__/ \___/|___/\__|3
###            |__/                   |_|
###
###  # # # # # #
###       #
###  # # # # # #
###

: '
hajime_3post
third part of linux installation
copyright (c) 2018 - 2025  |  oxo

GNU GPLv3 GENERAL PUBLIC LICENSE
This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
https://www.gnu.org/licenses/gpl-3.0.txt

@oxo@qoto.org


# description
  third part of a series
  arch linux installation: post
  branch archinst: after default archinstall

# dependencies
  archinstall, !REPO, 0init.sh, 1base.sh, 2conf.sh

# usage
  sh hajime/3post.sh [--online]

# example
  n/a

# '


#set -o errexit
#set -o nounset
set -o pipefail


# initial definitions

## script
script_name=3post.sh
developer=oxo
license=gplv3
initial_release=2018

## hardcoded variables
# user customizable variables

mirror_country=USA
mirror_amount=5

file_etc_motd=/etc/motd
file_hi_config="$HOME/hajime/install-config.sh"
file_hi_packages="$HOME/hajime/install-packages.sh"

#--------------------------------


# functions

sourcing ()
{
    ## configuration file
    [[ -f $file_hi_config ]] && source $file_hi_config

    ## sourcing conf_pkgs
    [[ -f $file_hi_packages ]] && source $file_hi_packages
}


args="$@"
getargs ()
{
    ## online installation
    [[ "$1" =~ online$ ]] && online=1
}


motd_remove ()
{
    sudo rm -rf $file_etc_motd
}


installation_mode ()
{
    ## online or offline mode
    if [[ $online -ne 1 ]]; then

	code_lbl=CODE
	code_dir="/home/$(id -un)/dock/3"
	repo_lbl=REPO
	repo_dir="/home/$(id -un)/dock/2"
	repo_re="\/home\/$(id -un)\/dock\/2"
	file_etc_pacman_conf=/etc/pacman.conf

    elif [[ "$online" -eq 1 ]]; then

	## dhcp connect
	sh hajime/0init.sh

    fi
}


reply ()
{
    # first silently entered character goes directly to $reply
    stty_0=$(stty -g)
    stty raw -echo
    reply=$(head -c 1)
    stty $stty_0
}


reply_single ()
{
    # first entered character goes directly to $reply
    stty_0=$(stty -g)
    stty raw #-echo
    reply=$(head -c 1)
    stty $stty_0
}


set_read_write ()
{
    # set /usr and /boot read-write
    sudo mount -o remount,rw  /usr
    sudo mount -o remount,rw  /boot
}


own_home ()
{
    sudo chown -R $(id -un):$(id -gn) /home/$(id -un)
}


modify_pacman_conf ()
{
    case $online in

	1 )
	    ## activate color
	    sudo sed -i 's/#Color/Color/' $file_etc_pacman_conf

	    ## activate verbose package lists
	    sudo sed -i 's/#VerbosePkgLists/VerbosePkgLists/' $file_etc_pacman_conf

	    ## activate parallel downloads
	    sudo sed -i 's/#Parallel/Parallel/' pacman.conf
	    #sudo awk '/VerbosePkgLists/ { print; print "ParallelDownloads = 5"; next }1' \
		#	$file_etc_pacman_conf > $file_etc_pacman_conf

	    ## activate multilib repository
	    sudo sed -i 's/\#\[multilib\]/\[multilib\]\nInclude \= \/etc\/pacman.d\/mirrorlist/' $file_etc_pacman_conf
	    ;;

	* )
	    ## update offline repository location (used in 2conf ch-root jail)
	    ## sed if ^[offline] is found substitute (s) the entire (.*) next line (n)
	    sudo sed -i "/^\[offline\]/{n;s/.*/Server = file:\/\/$repo_re/}" $file_etc_pacman_conf
	    ;;

    esac
}


pacman_init ()
{
    sudo pacman-key --init
    sudo pacman-key --populate archlinux
}


mount_repo ()
{
    repo_dev=$(lsblk -o label,path | grep "$repo_lbl" | awk '{print $2}')

    [[ -d $repo_dir ]] || mkdir -p "$repo_dir"

    mountpoint -q "$repo_dir"
    [[ $? -ne 0 ]] && sudo mount "$repo_dev" "$repo_dir"
}


get_offline_repo ()
{
    if [[ $online -ne 1 ]]; then

	mount_repo

	if [[ -z "$repo_dev" ]]; then

	    printf 'ERROR device REPO not found\n'
	    exit 20

	fi

    fi
}


mount_code ()
{
    code_dev=$(lsblk -o label,path | grep "$code_lbl" | awk '{print $2}')

    [[ -d $code_dir ]] || mkdir -p "$code_dir"

    mountpoint -q "$code_dir"
    [[ $? -ne 0 ]] && sudo mount "$code_dev" "$code_dir"
}


get_offline_code ()
{
    if [[ $online -ne 1 ]]; then

	mount_code

	if [[ -z "$code_dev" ]]; then

	    printf 'ERROR device CODE not found\n'
	    exit 30

	fi

    fi
}


create_directories ()
{
    # create mountpoint docking bays

    mkdir -p $HOME/dock/1
    mkdir -p $HOME/dock/2
    mkdir -p $HOME/dock/3
    mkdir -p $HOME/dock/4
    mkdir -p $HOME/dock/android
    mkdir -p $HOME/dock/transfer
    mkdir -p $HOME/dock/vlt


    # create xdg directories

    mkdir -p $HOME/.cache/temp
    mkdir -p $HOME/.cache/test
    mkdir -p $HOME/.config
    mkdir -p $HOME/.local/share
    mkdir -p $HOME/.logs
}


base_mutations ()
{
    ## add post core addditions
    sudo pacman -S --needed --noconfirm "${post_pkgs[@]}"
}


set_read_only ()
{
    # set /usr and /boot read-only
    sudo mount -o remount,ro  /usr
    sudo mount -o remount,ro  /boot
}


wrap_up ()
{
    # human info
    clear
    echo
    printf "congratulations, with your Arch Linux OS!\n"
    echo
    echo
    printf "your terminal is now ready to run independently\n"
    printf "proceed with your own personal configuration,\n"
    printf "or use an alternative desktop environment.\n"
    echo
    echo
    printf "continue with this installation series\n"
    printf "by running 4apps.sh (recommended):\n"
    echo
    printf "sh hajime/4apps.sh\n"
    echo
    echo
    printf "press any key to continue... "
    reply_single
    clear
    echo
    neofetch --ascii_distro arch_small --gtk3 off --gtk2 off --colors 3 3 3 7 3 4 --separator '     \t'
    sudo touch hajime/3post.done
}


autostart_next ()
{
    ## switch autostart via configuration file
    [[ -n $after_3post ]] && sh $HOME/hajime/4apps.sh
}


main ()
{
    sourcing
    getargs $args
    motd_remove
    installation_mode
    set_read_write
    own_home
    modify_pacman_conf
    pacman_init
    create_directories
    get_offline_repo
    get_offline_code
    base_mutations
    set_read_only
    wrap_up
    autostart_next
}

main
