#!/bin/bash


reply_single() {

        # first entered character goes directly to $reply
        stty_0=$(stty -g)
	stty raw #-echo
        reply=$(head -c 1)
        stty $stty_0

}


setup_wap() {

	echo
	echo
	printf "enter wap name: "
	read wap
	echo
	printf "enter password for $wap: "
	wpa_passphrase $wap > wap.wifi
	echo
	wpa_supplicant -B -i $interface -c wap.wifi

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
		pit="1"
	else
		# 1base.sh has not yet ran
		pit="0"
	fi

}


clear
printf "hajime_0init\n"
printf "(c) 2020 cytopyge\n"
echo
set -e


point_in_time


printf "connect to wireless access point? (y/N) "

reply_single


if printf "$reply" | grep -iq "^y" ; then

	if [[ "$pit"=="1" ]]; then
		ip a
		printf "please enter interface name: "
		read interface
		connect
		printf "connected\n"
	elif [[ "$pit"=="0" ]]; then
		interface="wlan0"
		setup_wap
		connect
		printf "$interface connected to $wap\n"

	fi
fi



if [[ $pit==1 ]]; then
	exit 10
else
	echo
	echo
	printf "install git & hajime? (Y/n) "

	reply_single

	if printf "$reply" | grep -iq "^n" ; then
		exit 0
	else
		install
	fi
fi


exit 0
