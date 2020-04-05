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
	sudo wpa_passphrase $wap > wap.wifi
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


printf "connect to wireless access point? (y/N) "


reply_single


if printf "$reply" | grep -iq "^y" ; then

	ip a
	printf "please enter interface name: "
	read interface
	setup_wap
	connect
	printf "$interface connected to $wap\n"

fi


point_in_time


if [[ $pit==1 ]]; then
	exit 0
else
	install
fi


exit 0
