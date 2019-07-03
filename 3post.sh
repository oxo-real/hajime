#!/bin/bash
#
##
###  _            _ _                                  _
### | |__   __ _ (_|_)_ __ ___   ___   _ __   ___  ___| |_
### | '_ \ / _` || | | '_ ` _ \ / _ \ | '_ \ / _ \/ __| __|
### | | | | (_| || | | | | | | |  __/ | |_) | (_) \__ \ |_
### |_| |_|\__,_|/ |_|_| |_| |_|\___| | .__/ \___/|___/\__|3
###            |__/                   |_|
###
###  _ _|_ _ ._    _  _
### (_\/|_(_)|_)\/(_|(/_
###   /      |  /  _|
###
### hajime_post
### cytopyge arch linux installation 'post'
### third part of a series
###
### (c) 2019 cytopyge
###
##
#


# user customizable variables
base_additions="lsof pacman-contrib mlocate alsi" #dash
bloat_ware="nano"


# functions

reply() {


	# first silently entered character goes directly to $reply
	stty_0=$(stty -g)
	stty raw -echo
	reply=$(head -c 1)
	stty $stty_0

}


dhcp_connect() {


	# dhcp connect
	ip a
	echo
	echo -n 'enter interface number '
	read interface_number
	interface=$(ip a | grep "^$interface_number" | awk '{print $2}' | sed 's/://')
	sudo dhcpcd -w $interface
	if [[ ! -z $interface ]] ; then
		echo "'$interface' connected"
	else
		printf "$interface not able to obtain lease\n"
		printf "exiting\n"
		exit
	fi
	ping -c 1 9.9.9.9
	ip a

}


set_read_write() {


	# set /usr and /boot read-write
	sudo mount -o remount,rw  /usr
	sudo mount -o remount,rw  /boot

}


modify_pacman_conf() {


	# modify pacman.conf

	## add color
	sudo sed -i 's/#Color/Color/' /etc/pacman.conf

	## add total download counter
	sudo sed -i 's/#TotalDownload/TotalDownload/' /etc/pacman.conf

	## add multilib repository
	sudo sed -i 's/\#\[multilib\]/\[multilib\]\nInclude \= \/etc\/pacman.d\/mirrorlist/' /etc/pacman.conf

}


create_directories() {


	# create mountpoint docking bays

	sudo mkdir -p /dock/1
	sudo mkdir -p /dock/2
	sudo mkdir -p /dock/3
	sudo mkdir -p /dock/4


	# create user_ directories

	mkdir -p ~/backup_
	mkdir -p ~/data_
	mkdir -p ~/download_
	mkdir -p ~/keys_
	mkdir -p ~/media_
	mkdir -p ~/settings_
	mkdir -p ~/test_
	mkdir -p ~/temp_
	mkdir -p ~/todo_

}


base_mutations() {


	# update package databases
	sudo pacman -Syu


	# yay, a packagemanager written in go
	## build yay
	mkdir -p ~/tmp/yay
	git clone -q https://aur.archlinux.org/yay.git ~/tmp/yay
	cd ~/tmp/yay

	## install yay
	makepkg -si
	cd
	rm -rf ~/tmp


	# add, remove and configure to the standard base packages

	## add base addditions
	yay -S --noconfirm $base_additions

	## remove core system bloat
	yay -Rns --noconfirm $bloat_ware


	# Debian Almquist shell (DASH)

	## dsah is a POSIX-compliant implementation of /bin/sh
	## pacman hook is in: ~/.dot/code/pacman/hooks/relink_dash.hook

	## linking /bin/sh
	#sudo ln -sfT dash /usr/bin/sh

}


system_update() {


	# system update

	## [[[git updater version as of 20190525_085600]]]
	## update mirrorlist
	sudo cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.old
	sudo reflector --verbose --country 'Netherlands' -l 5 --sort rate --save /etc/pacman.d/mirrorlist

	## some info
	yay -Ps

	echo
	printf "package statistics\n"
	printf "%7s %s\n" "$(yay -Qe | wc -l)" "explicit"
	printf "%7s %s\n" "$(yay -Qd | wc -l)" "dependend"
	printf "\033[1m%7s %s\033[0m\n" "$(yay -Q | wc -l)" "total count"
	#total count matches: -4 + $(ls -ila /var/lib/pacman/local | grep wc -l)
	printf "%7s %s\n" "$(yay -Qn | wc -l)" "native"
	printf "%7s %s\n" "$(yay -Qm | wc -l)" "foreign"
	echo
	printf "file statistics\n"
	printf "\033[1m%7s %s\033[0m\n" "$(yay -Ql | wc -l)" "total count"
	printf "  top10 files per package\n"
	yay -Ql | awk {'print $1'} | uniq -c | sort -k1,1nr | head
	echo

	printf "arch linux news (Pw)\n"
	if [ -z $(yay -Pw) ]; then
		printf "no recent entries\n"
	else
		yay -Pw
		echo
		printf "Press any key to continue "
		reply
	fi
	echo


	# update packages
	clear
	printf "package update (Syu)\n"
	yay -Syu
	echo


	# cleaning up
	printf "package cleanup\n"
	#printf "yay\n"
	#printf "[Rns Qtdq]\n"
	#yay -Rns $(yay -Qtdq) 2>/dev/null
	printf "> done\n"

	printf "[c]\n"
	yay -c
	printf "> done\n"

	printf "paccache\n"
	printf "[rv]\n"
	paccache -rv
	printf "> done\n"
	echo


	# show missing package files

	## i3blocks is filtered out from results
	printf "missing package files\n"
	#printf "yay\n"
	printf "[Qk]\n"
	yay -Qk | grep -v '0 m' || printf " no missing package files detected\n"
	echo


	# updatedb
	## in order to user locate (faster than find)
	## mlocate is required
	printf "update locate database\n"
	sudo updatedb
	printf "done\n"

}


set_read_only() {


	# set /usr and /boot read-only
	sudo mount -o remount,ro  /usr
	sudo mount -o remount,ro  /boot

}


reply_single() {

        # first entered character goes directly to $reply
        stty_0=$(stty -g)
	stty raw #-echo
        reply=$(head -c 1)
        stty $stty_0

}


conclusion() {


	# finishing
	sudo touch hajime/3post.done


	# human info
	clear
	echo
	printf "congratulations, with your Arch Linux OS!\n"
	echo
	printf "your terminal is now ready to run\n"
	echo
	printf "proceed with your own personal configuration,\n"
	printf "use an alternative desktop environments\n"
	printf "or continue with this installation series by entering:\n"
	echo
	printf "sh hajime/4apps.sh\n"
	echo
	printf "press any key to continue... "
	reply_single
	clear
	echo
	alsi

}


# execution

dhcp_connect
set_read_write
modify_pacman_conf
create_directories
base_mutations
system_update
set_read_only
conclusion
