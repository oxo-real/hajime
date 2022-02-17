#!/usr/bin/env bash
#
##
###  _            _ _                  _       _ _
### | |__   __ _ (_|_)_ __ ___   ___  (_)_ __ (_) |_
### | '_ \ / _` || | | '_ ` _ \ / _ \ | | '_ \| | __|
### | | | | (_| || | | | | | | |  __/ | | | | | | |_
### |_| |_|\__,_|/ |_|_| |_| |_|\___| |_|_| |_|_|\__|0
###            |__/
###  _ _|_ _ ._    _  _
### (_\/|_(_)|_)\/(_|(/_
###   /      |  /  _|
###
### hajime_0init
### zeroth part of six scripts in total
### helper file to get lined up after archiso boot
### copyright (c) 2020 - 2022  |  cytopyge
###
### GNU GPLv3 GENERAL PUBLIC LICENSE
### This file is part of hajime.
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
### y3l0b3b5z2u=:matrix.org @cytopyge@mastodon.social
###
##
#

## dependencies
#	archiso, REPO

## usage
#	sh hajime/0init.sh

## example
#	none


# initial definitions

## script
script_name="0init.sh"
developer="cytopyge"
licence='gplv3'

## hardcoded variables
#	none

#--------------------------------



## offline installation
#	see point_in_time (if pit=0)


reply_single()
{
	# first entered character goes directly to $reply
	stty_0=$(stty -g)
	stty raw #-echo
	reply=$(head -c 1)
	stty $stty_0
}


header()
{
	clear
	printf "$script_name\n"
	printf "$initial_release_year"
	[[ $initial_release_year -ne $current_year ]] && printf " - $current_year "
	printf " |  $developer\n"
	echo
	set -e
}


set_offline()
{
	printf "offline? (Y/n) "
	reply_single

	case $reply in

		y|Y)
			offline=1
			;;

		*)
			select_interface
			;;

	esac
	echo
}


select_interface()
{
	if printf "$reply" | grep -iq "^y" ; then

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

	fi
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
			;;

		*)
			git clone https://gitlab.com/cytopyge/hajime
			pacman -Sy --noconfirm git
			;;

	esac

	echo
	printf "sh hajime/1base.sh\n"
	echo
}


mount_repo()
{
	repo_lbl='REPO'
	repo_dev=$(lsblk -o label,path | grep "$repo_lbl" | awk '{print $2}')
	#local mountpoint=$(mount | grep $repo_dir)

	[[ -d $repo_dir ]] || mkdir -p "$repo_dir"

	mount "$repo_dev" "$repo_dir"
	#[[ -n $mountpoint ]] || mount "$repo_dev" "$repo_dir"
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
	#local mountpoint=$(mount | grep $code_dir)

	[[ -d $code_dir ]] || mkdir -p "$code_dir"

	mount "$code_dev" "$code_dir"
	#[[ -n $mountpoint ]] || mount "$code_dev" "$code_dir"
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
