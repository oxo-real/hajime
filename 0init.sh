#!/bin/sh

# just hit enter when eth
read -p "wireless access point? " wap

if [[ -z $wap ]]; then
	connect
else
	setup_wap
fi

setup_wap() {

	echo "password? "
	wpa_passphrase $wap > wap.wifi
	wpa_supplicant -B -i wlan0 -c wap.wifi
	connect

}


connect() {

	dhcpcd
	install

}


install() {

	pacman -Sy --noconfirm git
	git clone https://gitlab.com/cytopyge/hajime

}

echo "sh hajime/1base.sh"
