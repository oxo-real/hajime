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
### helper file to get lined up after archiso boot
###
### 2020 - 2022  |  cytopyge
###
##
#


# initial definitions

## initialize hardcoded variables
script_name="hajime_0init"
initial_release_year="2020"
current_year=$(date "+%Y")
developer="cytopyge"


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
	else
		# 1base.sh has not yet ran
		pit=0
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
			mount_repo

			cp -pr /root/tmp/code/hajime /root

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
	repo_dir='/root/tmp/repo'
	repo_dev=$(lsblk -o label,path | grep "$repo_lbl" | awk '{print $2}')
	local mountpoint=$(mount | grep $repo_dir)

	[[ -d $repo_dir ]] || mkdir -p "$repo_dir"

	[[ -n $mountpoint ]] || mount "$repo_dev" "$repo_dir"
}


mount_code()
{
	code_lbl='CODE'
	code_dir='/root/tmp'
	code_dev=$(lsblk -o label,path | grep "$repo_lbl" | awk '{print $2}')

	[[ -d $code_dir ]] || mkdir -p "$code_dir"

	mount "$code_dev" "$code_dir"
}


main()
{
	header
	set_offline
	point_in_time
	install_or_exit
}

main
