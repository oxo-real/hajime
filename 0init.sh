#!/bin/sh


reply_single() {

        # first entered character goes directly to $reply
        stty_0=$(stty -g)
	stty raw #-echo
        reply=$(head -c 1)
        stty $stty_0

}


setup_wap() {

	echo "enter password for $wap "
	wpa_passphrase $wap > wap.wifi
	wpa_supplicant -B -i $interface -c wap.wifi

}


connect() {

	dhcpcd -w

}


install() {

	pacman -Sy --noconfirm git
	git clone https://gitlab.com/cytopyge/hajime
	echo
	echo "sh hajime/1base.sh"
	echo

}


printf "hajime_0init\n"
echo
printf "connect to wireless access point? (y/N) "

reply_single

if printf "$reply" | grep -iq "^y" ; then
	interface="wlan0"
	setup_wap
	connect
	# not so neat, but ....
	printf "connected succesfully"
else
	#interface="eth0"
	connect
	# not so neat, but ....
	printf "connected succesfully"
fi


if [[ -f ~/hajime/1base.done ]]; then
	# 1base.sh already ran
	exit 10
else
	# 1base.sh has not yet ran
	printf "install git & hajime? (Y/n) "

	reply_single

	if printf "$reply" | grep -iq "^n" ; then
		exit 0
	else
		install
	fi
fi


exit 0
