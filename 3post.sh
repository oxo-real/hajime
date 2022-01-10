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
### (c) 2019 - 2021 cytopyge
###
##
#


# user customizable variables
## base-devel packages retrieved with: yay -Qg | awk '{print $2}'
base_devel="autoconf automake binutils bison fakeroot file findutils flex gawk gcc gettext grep groff gzip libtool m4 make pacman patch pkgconf sed sudo systemd texinfo util-linux which"
base_additions="lsof pacman-contrib mlocate neofetch wl-clipboard-git"
bloat_ware="" # there seems to be no more bloatware since kernel v536 (nano was removed)
mirror_country="Sweden"
mirror_amount="5"


# functions


reply() {

	# first silently entered character goes directly to $reply
	stty_0=$(stty -g)
	stty raw -echo
	reply=$(head -c 1)
	stty $stty_0

}


reply_single() {

        # first entered character goes directly to $reply
        stty_0=$(stty -g)
	stty raw #-echo
        reply=$(head -c 1)
        stty $stty_0

}


dhcp_connect() {

	sh hajime/0init.sh

}


own_home() {

	cd $HOME
	sudo rm -rf .

}


set_read_write() {

	# set /usr and /boot read-write
	sudo mount -o remount,rw  /usr
	sudo mount -o remount,rw  /boot

}


modify_pacman_conf() {

	# modify pacman.conf
	file_etc_pacman_conf="/etc/pacman.conf"

	## add color
	sudo sed -i 's/#Color/Color/' $file_etc_pacman_conf

	## add total download counter
	#sudo sed -i 's/#TotalDownload/TotalDownload/' $file_etc_pacman_conf

	## add verbose package lists
	sudo sed -i 's/#VerbosePkgLists/VerbosePkgLists/' $file_etc_pacman_conf

	## add parallel downloads
	sudo awk '/VerbosePkgLists/ { print; print "ParallelDownloads = 5"; next }1' \
		$file_etc_pacman_conf > $file_etc_pacman_conf

	## add multilib repository
	sudo sed -i 's/\#\[multilib\]/\[multilib\]\nInclude \= \/etc\/pacman.d\/mirrorlist/' $file_etc_pacman_conf

}


create_directories() {

	# create mountpoint docking bays

	sudo mkdir -p $HOME/dock/1
	sudo mkdir -p $HOME/dock/2
	sudo mkdir -p $HOME/dock/3
	sudo mkdir -p $HOME/dock/4
	sudo mkdir -p $HOME/dock/android
	sudo mkdir -p $HOME/dock/transfer
	sudo mkdir -p $HOME/dock/vlt



	# create xdg directories

	mkdir -p $HOME/.local/share/archive
	mkdir -p $HOME/.local/share/backup
	mkdir -p $HOME/.local/share/data
	mkdir -p $HOME/.local/share/download
	mkdir -p $HOME/.local/share/keys
	mkdir -p $HOME/.local/share/media
	mkdir -p $HOME/.local/share/todo
	mkdir -p $HOME/.cache/temp
	mkdir -p $HOME/.cache/test
	mkdir -p $HOME/.config
	mkdir -p $HOME/.logs
	mkdir -p $HOME/.dot

}


base_mutations() {

	# own home
	sudo chown -R $USER:wheel $HOME

	# update package databases
	sudo pacman -Sy

	# install base-devel package group
	sudo pacman -S base-devel
	#sudo pacman -S $base_devel

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
	for package in $base_additions;
	do

		yay -S --needed --noconfirm $package

	done

	## remove core system bloat
	#yay -Rns --noconfirm $bloat_ware

}


system_update() {

	#[TODO] updater

	# system update

	## [[[git updater version as of 20190525_085600]]]
	## update mirrorlist
	sudo cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.old
	sudo reflector --verbose --country $mirror_country -l $mirror_amount \
		--sort rate --save /etc/pacman.d/mirrorlist

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


conclusion() {

	# finishing
	sudo touch hajime/3post.done


	# human info
	clear
	echo
	printf "congratulations, with your new Arch Linux OS!\n"
	echo
	echo
	printf "your terminal is now ready to run independently\n"
	printf "proceed with your own personal configuration,\n"
	printf "or use an alternative desktop environment.\n"
	echo
	echo
	printf "continue with this installation series"
	printf "by running 4apps.sh (recommended):\n"
	echo
	printf "sh hajime/4apps.sh\n"
	echo
	echo
	printf "press any key to continue... "
	reply_single
	clear
	echo
	neofetch --gtk3 off

}


# execution

dhcp_connect
set_read_write
#own_home
modify_pacman_conf
create_directories
base_mutations
system_update
set_read_only
conclusion
