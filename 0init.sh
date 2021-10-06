#!/bin/bash
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
### helper file to get lined up in archiso
###
### (c) 2020 - 2021 cytopyge
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


setup_wap() {

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


connect() {

	sudo dhcpcd -w $interface

}


install() {

	pacman -Sy --noconfirm git
	git clone https://gitlab.com/cytopyge/hajime
	echo
	printf "sh hajime/1base.sh\n"
	echo

}


point_in_time() {

	if [[ -f $HOME/hajime/1base.done ]]; then
		# 1base.sh already ran
		pit=1
	else
		# 1base.sh has not yet ran
		pit=0
	fi

}


select_interface() {

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


install_or_exit() {

	if [[ "$pit" == "1" ]]; then
		exit 0
	else
		install
		exit 0
	fi

}


clear
printf "$script_name\n"
printf "(c) $initial_release_year"
[[ $initial_release_year -ne $current_year ]] && printf " - $current_year "
printf " $developer\n"
echo
set -e


printf "connect to wireless access point? (y/N) "
echo
reply_single
select_interface
point_in_time
install_or_exit
