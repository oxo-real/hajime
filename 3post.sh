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
copyright (c) 2018 - 2024  |  oxo

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

# dependencies
  archiso, REPO, 0init.sh, 1base.sh, 2conf.sh

# usage
  sh hajime/3post.sh

# example
  n/a

# '


#set -o errexit
set -o nounset
set -o pipefail
#

# initial definitions

## script
script_name='3post.sh'
developer='oxo'
license='gplv3'
initial_release='2018'

## hardcoded variables
# user customizable variables

## offline installation
offline=1
code_lbl='CODE'
code_dir="/home/$(id -un)/dock/3"
repo_lbl='REPO'
repo_dir="/home/$(id -un)/dock/2"
repo_re="\/home\/$(id -un)\/dock\/2"
file_etc_pacman_conf='/etc/pacman.conf'

post_core_additions='archlinux-keyring lsof mlocate neofetch neovim pacman-contrib wl-clipboard'
bloat_ware="" # there seems to be no more bloatware since kernel v536 (nano was removed)
mirror_country='Sweden'
mirror_amount='5'

#--------------------------------


# functions


reply()
{
    # first silently entered character goes directly to $reply
    stty_0=$(stty -g)
    stty raw -echo
    reply=$(head -c 1)
    stty $stty_0
}


reply_single()
{
    # first entered character goes directly to $reply
    stty_0=$(stty -g)
    stty raw #-echo
    reply=$(head -c 1)
    stty $stty_0
}


check_label_exist()
{
    lsblk -o label | grep "$lbl" #> /dev/null 2>&1
    if [[ "$?" -ne "0" ]]; then

	printf "$lbl source not found, exiting\n"
	exit 10

    fi
}


check_mountpoint()
{
    # check if device with label is already mounted

    mount -l | grep "$lbl" #> /dev/null 2>&1

    case "$?" in
	0)
	    local lblmountpoint="$(mount -l | grep "$lbl" | awk '{print $3}')"
	    printf "device with label $lbl already mounted on $lblmountpoint\n"
	    ;;
    esac
}


dhcp_connect()
{
    sh hajime/0init.sh
}


set_read_write()
{
    # set /usr and /boot read-write
    sudo mount -o remount,rw  /usr
    sudo mount -o remount,rw  /boot
}


own_home()
{
    sudo chown -R $(id -un):$(id -gn) /home/$(id -un)
}


modify_pacman_conf()
{
    case $offline in

	1)
	    ## set offline repo
	    sudo sed -i "/^\[offline\]/{n;s/.*/Server = file:\/\/$repo_re/}" $file_etc_pacman_conf
	    #sudo sed -i "s|\/repo|$HOME\/repo|" $file_etc_pacman_conf
	    ;;

	*)
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

    esac
}


pacman_init()
{
    sudo pacman-key --init
    sudo pacman-key --populate archlinux
}


mount_repo()
{
    lbl="$repo_lbl"

    check_label_exist
    check_mountpoint

    repo_dev=$(lsblk -o label,path | grep "$lbl" | awk '{print $2}')

    [[ -d $repo_dir ]] || mkdir -p "$repo_dir"

    sudo mount "$repo_dev" "$repo_dir"

    lbl=''
    unset lbl
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
    lbl="$code_lbl"

    check_label_exist
    check_mountpoint

    code_dev=$(lsblk -o label,path | grep "$lbl" | awk '{print $2}')

    [[ -d $code_dir ]] || mkdir -p "$code_dir"

    sudo mount "$code_dev" "$code_dir"

    lbl=''
    unset lbl
}


get_offline_code()
{
    case $offline in
	1)
	    mount_code
	    ;;
    esac
}


create_directories() {
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


base_mutations()
{
    ## add post core addditions
    for package in $post_core_additions;
    do

	sudo pacman -S --needed --noconfirm $package

    done

    ## remove base system bloat
    #pacman -Rns --noconfirm $bloat_ware
}


set_read_only()
{
    # set /usr and /boot read-only
    sudo mount -o remount,ro  /usr
    sudo mount -o remount,ro  /boot
}


wrap_up()
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


main()
{
    dhcp_connect
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
}

main
