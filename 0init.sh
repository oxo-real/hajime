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
copyright (c) 2020 - 2024  |  oxo

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
  archiso, REPO

# usage
  sh hajime/0init.sh

# example
  mkdir tmp
  lsblk
  mount /dev/sdX tmp
  sh tmp/code/hajime/0init.sh

# '


set -o errexit
#set -o nounset
set -o pipefail

# initial definitions

## script
script_name='0init.sh'
developer='oxo'
license='gplv3'
initial_release='2020'

## hardcoded variables
online_repo='https://codeberg.org/oxo/hajime'

#--------------------------------



## offline installation
#   see point_in_time (if pit=0)


reply_single()
{
    # reply_functions

    # first entered character goes directly to $reply
    stty_0=$(stty -g)
    stty raw #-echo
    reply=$(head -c 1)
    stty $stty_0
}


header()
{
    current_year=$(date +%Y)
    clear
    printf "$script_name\n"
    printf "$initial_release"
    [[ $initial_release -ne $current_year ]] && printf " - $current_year"
    printf "  |  $developer\n"
    echo
    set -e
}


set_offline()
{
    printf "offline? (Y/n) "
    reply_single

    case $reply in

	n|N)
	    select_interface
	    ;;

	*)
	    offline=1
	    ;;

    esac

    echo
    echo
}


select_interface()
{
    #if printf "$reply" | grep -iq "^y" ; then

	ip a
	echo

	printf "please enter interface number: "
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


setup_wap()
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


connect()
{
    sudo dhcpcd -w $interface
    sleep 2
}


point_in_time()
{
    if [[ -f $HOME/hajime/1base.done ]]; then
	# 1base.sh already ran
	pit=1
	#code_dir	comes from script that has called 0init
	#repo_dir	comes from script that has called 0init
	#repo_re	comes from script that has called 0init

    else
	# 1base.sh has not yet ran
	pit=0
	code_dir='/root/tmp'
	repo_dir='/root/tmp/repo'
	repo_re='\/root\/tmp\/repo'
    fi
}


install_or_exit()
{
    if [[ "$pit" == "1" ]]; then
	exit 0
    else
	install
	exit 0
    fi
}


install()
{
    case $offline in

	1)
	    ## mount repo
	    get_offline_repo

	    ## copy hajime to /root
	    cp -pr /root/tmp/code/hajime /root

	    ## update pacman.conf
	    cp -pr /root/hajime/misc/ol_pacman.conf /etc/pacman.conf
	    pacman -Sy

	    ## set environment
	    export OFFLINE=1
	    ;;

	*)
	    pacman -Syy
	    pacman-key --init
	    pacman-key --populate
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
	    ;;

    esac

    touch /root/hajime/0init.done

    echo
    printf "sh hajime/1base.sh\n"
    echo
}


mount_repo()
{
    repo_lbl='REPO'
    repo_dev=$(lsblk -o label,path | grep "$repo_lbl" | awk '{print $2}')

    [[ -d $repo_dir ]] || mkdir -p "$repo_dir"

    mount "$repo_dev" "$repo_dir"
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

    mount "$code_dev" "$code_dir"
}


get_offline_code()
{
    case $offline in

	1)
	    mount_code
	    ;;

    esac
}


main()
{
    header
    set_offline
    point_in_time
    install_or_exit
}

main
