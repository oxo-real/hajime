#! /usr/bin/env sh

###  _            _ _                  _       _ _
### | |__   __ _ (_|_)_ __ ___   ___  (_)_ __ (_) |_
### | '_ \ / _` || | | '_ ` _ \ / _ \ | | '_ \| | __|
### | | | | (_| || | | | | | | |  __/ | | | | | | |_
### |_| |_|\__,_|/ |_|_| |_| |_|\___| |_|_| |_|_|\__|0
###            |__/
###
###  # # # # # #
###       #
###  # # # # # #
###

: '
hajime_0init
initial part of linux installation
copyright (c) 2020 - 2025  |  oxo

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
zeroth part of five scripts in total
helper script to bootstrap hajime up after archiso boot

# dependencies
  REPO

# usage
  sh hajime/0init.sh [--config $custom_conf_file] [--online]

# example
  mkdir tmp
  lsblk
  mount /dev/sdX tmp
  sh tmp/code/hajime/0init.sh

# '


#set -o errexit
#set -o nounset
set -o pipefail

# initial definitions

## script
script_name=0init.sh
developer=oxo
license=gplv3
initial_release=2020

# hardcoded variables
online_repo=https://codeberg.org/oxo/hajime
file_hi_config=/root/tmp/code/hajime/install-config.sh

#--------------------------------

sourcing ()
{
    ## configuration file
    [[ -f $file_hi_config ]] && source $file_hi_config
}


args="$@"
getargs ()
{
    while :; do

	case "$1" in

	    -c | --config )
		shift
		## override default configuration file
		[[ -f "$1" ]] && file_hi_config="$1"
		shift
		;;

	    --online )
		online=1
		shift
		;;

	    -- )
		shift
		## override default configuration file
		[[ -f "$1" ]] && file_hi_config="$1"
		break
		;;

            * )
		break
		;;

	esac

    done
}


define_text_appearance()
{
    ## text color
    fg_magenta='\033[0;35m'	# magenta
    fg_green='\033[0;32m'	# green
    fg_red='\033[0;31m'		# red

    ## text style
    st_def='\033[0m'		# default
    st_ul=`tput smul`		# underline
    st_bold=`tput bold`		# bold
}


reply_single ()
{
    # reply_functions

    # first entered character goes directly to $reply
    stty_0=$(stty -g)
    stty raw #-echo
    reply=$(head -c 1)
    stty $stty_0
}


header ()
{
    [[ "$pit" -eq 0 ]] && clear
    current_year="$(date +%Y)"
    printf 'hajime - %s\n' "$script_name"
    printf 'copyright (c) %s' "$initial_release"
    [[ $initial_release -ne $current_year ]] && printf ' - %s' "$current_year"
    printf '  |  %s\n' "$developer"
    echo
}


point_in_time ()
{
    if [[ -f $HOME/hajime/1base.done ]]; then

	# 1base.sh already ran
	## later in time
	pit=1
	# further data comes from calling script (3post)

    else

	# 1base.sh has not yet ran
	## beginning of times
	pit=0

	## we have no ~/dock/2,3 yet
	## therefore we use /root/tmp for the mountpoints
	code_lbl=CODE
	code_dir=/root/tmp/code
	repo_lbl=REPO
	repo_dir=/root/tmp/repo
	repo_re=\/root\/tmp\/repo

	file_etc_pacman_conf=/etc/pacman.conf
	file_misc_pacman_conf=/root/hajime/misc/ol_pacman.conf

    fi
}


config_file_warning ()
{
    if [[ "$pit" -eq 0 && -n "$file_hi_config" ]]; then

	printf "${st_bold}WARNING config-file${st_def} detected: %s\n" "$(realpath "$file_hi_config")"
	echo
	printf 'move this file if a interactive installation is preferred\n'
	printf 'else this file WILL be used for automatic installation\n'
	echo
	printf 'make 100%% sure that:\n'
	printf "1 the filename is correct\n"
	printf "2 all the parameters in the file are correct\n"
	echo
	printf 'continue with automatic installation? [y/N] '

	reply_single
	echo

	if printf "$reply" | grep -iq "^y"; then

	    :

	else

	    printf 'installation aborted\n'
	    exit 1

	fi

    fi
}


set_online ()
{
    [[ $online -eq 1 ]] && select_interface
}


select_interface ()
{
    #if printf "$reply" | grep -iq "^y" ; then

	ip a
	echo

	printf "please enter network interface number: "
	read interface_number

	# translate number to interface name
	interface=$(ip a | grep "^$interface_number" | \
	    awk '{print $2}' | sed 's/://')

	sudo ip link set $interface up
	setup_wap
	connect

	printf "$interface connected to $wap\n"

    #fi
}


setup_wap ()
{
    echo
    wap_list=$(sudo iw dev $interface scan | grep SSID: | sed 's/SSID: //' | \
	## awk removes leading and trailing whitespace
	## nl adds line numbers
	awk '{$1=$1;print}' | sort | uniq | sort | nl)

    printf "visible wireless access points (wap's):\n"
    printf "$wap_list\n"
    echo
    printf "please enter wap number: "
    read wap_number
    wap=$(echo "$wap_list" | awk '{if ($1=='"$wap_number"') {print $2}}')
    echo
    printf "enter password for "$wap": "
    sudo wpa_passphrase "$wap" > wap.wifi
    echo
    sudo wpa_supplicant -B -i $interface -c wap.wifi
}


connect ()
{
    sudo dhcpcd -w $interface
    sleep 2
}


install_or_exit ()
{
    if [[ $pit -eq 1 ]]; then

	set_online
	exit 0

    else

	prepare_install
	autostart_next

    fi
}


prepare_install ()
{
    if [[ $online -ne 1 ]]; then
	## offline

	## mount repo
	get_offline_repo

	## mount code
	## code is already mounted manually
	## it is the very reason this script runs :)

	## copy hajime to /root
	## from here hajime will be ran
	cp --preserve --recursive "$code_dir"/hajime /root


	## copy pacman.conf
	# cp --preserve --recursive "$file_misc_pacman_conf" "$file_etc_pacman_conf"
	#
	## update pacman.conf
	# sed -i "s#0init_repo_here#$repo_dir#" "$file_etc_pacman_conf"
	#
	## force a refresh of the package database
	#pacman -Syy


    elif [[ $online -eq 1 ]]; then
	## online

	set_online

	##must be similar to 1base configure_pacman
	pacman-key --init
	pacman-key --populate

	pacman -Syy

	pacman -Sy --noconfirm git

	git clone $online_repo

	case $? in

	    0)
		:
		;;

	    *)
		printf 'repo already exists\n'
		mv hajime hajime"$($date +'%s')"
		#cp -r hajime hajime"$($date +'%s')"
		;;

	esac

    fi

    touch /root/hajime/0init.done

    echo
    printf 'sh hajime/1base.sh\n'
    echo
}


mount_repo ()
{
    # repo_lbl='REPO'
    repo_dev=$(lsblk -o label,path | grep "$repo_lbl" | awk '{print $2}')

    [[ -d $repo_dir ]] || mkdir -p "$repo_dir"

    mountpoint -q "$repo_dir"
    [[ $? -ne 0 ]] && sudo mount "$repo_dev" "$repo_dir"
}


get_offline_repo ()
{
    [[ $online -ne 1 ]] && mount_repo

    if [[ -z "$repo_dev" ]]; then

	printf 'ERROR device REPO not found\n'
	exit 30

    fi
}


autostart_next ()
{
    ## switch autostart via configuration file
    [[ -n $after_0init ]] && sh /root/hajime/1base.sh
}


main ()
{
    sourcing
    getargs $args
    define_text_appearance
    point_in_time
    header
    config_file_warning
    install_or_exit
}

main
