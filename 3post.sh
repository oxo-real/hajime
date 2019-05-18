#!/bin/sh
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
base_additions="lsof pacman-contrib mlocate dash"
bloat_ware="nano"


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


# modify pacman.conf

## add color
sudo sed -i 's/#Color/Color/' /etc/pacman.conf

## add total download counter
sudo sed -i 's/#TotalDownload/TotalDownload/' /etc/pacman.conf

## add multilib repository
sudo sed -i 's/\#\[multilib\]/\[multilib\]\nInclude \= \/etc\/pacman.d\/mirrorlist/' /etc/pacman.conf


# set /usr and /boot read-write
sudo mount -o remount,rw  /usr
sudo mount -o remount,rw  /boot


# update and sync package repository, upgrade system

## -S, --sync		(synchronize packages)
## -y, --refresh	(download fresh package databases from the server)
## -u, --sysupgrade	(upgrade all packages that are out-of-date)
sudo pacman -Syu --noconfirm


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
mkdir -p ~/todo_

# yay, a packagemanager written in go

## build yay
mkdir -p ~/tmp/yay
git clone -q https://aur.archlinux.org/yay.git ~/tmp/yay
cd ~/tmp/yay

## install yay
makepkg -si
cd
sudo rm -rf ~/tmp


# install pacman tools
yay -S --noconfirm $base_additions


# remove system bloat
yay -Rns --noconfirm $bloat_ware


# Debian Almquist shell (DASH) a POSIX-compliant implementation of /bin/sh
## pacman hook is in: ~/.dot/code/pacman/hooks/relink_dash.hook

## linking /bin/sh
ln -sfT dash /usr/bin/sh



# set /usr and /boot read-only
sudo mount -o remount,ro  /usr
sudo mount -o remount,ro  /boot


# human info
echo
echo 'sh hajime/4apps.sh'

# finishing
sudo touch hajime/3post.done
