#!/bin/bash
#
##
###  _            _ _                                   __
### | |__   __ _ (_|_)_ __ ___   ___    ___ ___  _ __  / _|
### | '_ \ / _` || | | '_ ` _ \ / _ \  / __/ _ \| '_ \| |_
### | | | | (_| || | | | | | | |  __/ | (_| (_) | | | |  _|
### |_| |_|\__,_|/ |_|_| |_| |_|\___|  \___\___/|_| |_|_|  2
###            |__/
###
###  _ _|_ _ ._    _  _
### (_\/|_(_)|_)\/(_|(/_
###   /      |  /  _|
###
### hajime_conf
### cytopyge arch linux installation 'configuration'
### second part of a series
###
### (c) 2019 cytopyge
###
##
#


clear


# user customizable variables
time_zone="Europe/Amsterdam"
locale_conf="LANG=en_US.UTF-8"
vconsole_conf="FONT=ter-v32n"
mirror_country="Netherlands"
mirror_amount="5"
hostname="host"
username="user"
bootloader_timeout="2"
bootloader_editor="0"
## core applications
linux_kernel="linux-headers"
linux_lts_kernel="linux-lts linux-lts-headers"
command_line_editor="neovim"
install_helpers="reflector wl-clipboard"
wireless="wpa_supplicant wireless_tools iw"
secure_connections="openssh"


# time settings
## set time zone
ln -sf /usr/share/zoneinfo/$time_zone /etc/localtime
## set hwclock
hwclock --systohc


# locale settings
sed -i "/^#en_US.UTF-8 UTF-8/c\en_US.UTF-8 UTF-8" /etc/locale.gen
locale-gen
echo $locale_conf > /etc/locale.conf


# vconsole settings
echo $vconsole_conf > /etc/vconsole.conf


# network configuration

## set hostname

function set_hostname() {

	read -p "change hostname '$hostname'? (y/N) " -n 1 -r

	if [[ $REPLY =~ ^[Yy]$ ]] ; then
		echo
		printf "enter hostname: "
		read hostname
		echo
		printf "hostname '$hostname' entered, correct? (Y/n) \n"
		read hostname_correct

			if [[ $REPLY =~ ^[Nn]$ ]] ; then
				echo
				set_hostname
			else
				printf "using '$hostname' as hostname\n"
			fi
	else
		printf "using '$hostname' as hostname\n"
	fi

}

set_hostname

## create hostname file
printf "$hostname" > /etc/hostname

## add matching entries to hosts file
printf "127.0.0.1	localhost.localdomain	localhost" >> /etc/hosts
printf "::1		localhost.localdomain	localhost" >> /etc/hosts
printf "127.0.1.1	$hostname.localdomain	$hostname" >> /etc/hosts


# set root password
whoami
passwd


# install helpers
pacman -S --noconfirm $install_helpers


# configuring the mirrorlist

## backup old mirrorlist
cp /etc/pacman.d/mirrorlist /etc/pacman.d/`date "+%Y%m%d%H%M%S"`_mirrorlist.backup

## select fastest mirrors
reflector --verbose --country $mirror_country -l $mirror_amount --sort rate --save /etc/pacman.d/mirrorlist


# update repositories and install core applications
pacman -Syu --noconfirm $linux_kernel $linux_lts_kernel $command_line_editor $wireless $secure_connections


# installing the EFI boot manager

## install boot files
bootctl install

## boot loader configuration
echo 'default arch' > /boot/loader/loader.conf
printf "timeout $bootloader_timeout" >> /boot/loader/loader.conf
printf "editor $bootloader_editor" >> /boot/loader/loader.conf
echo 'console-mode max' >> /boot/loader/loader.conf


# configure mkinitcpio

## create an initial ramdisk environment (initramfs)
## enable systemd HOOKS
sed -i "/^HOOKS/c\HOOKS=(base systemd autodetect keyboard sd-vconsole modconf block sd-encrypt sd-lvm2 filesystems fsck)" /etc/mkinitcpio.conf


# adding boot loader entries

## bleeding edge kernel
echo 'title arch' > /boot/loader/entries/arch.conf
echo 'linux /vmlinuz-linux' >> /boot/loader/entries/arch.conf
echo 'initrd /initramfs-linux.img' >> /boot/loader/entries/arch.conf
[ ! -d /dev/mapper/vg0-lv_swap ] && echo "options rd.luks.name=`blkid | grep crypto_LUKS | awk '{print $2}' | cut -d '"' -f2`=cryptlvm root=UUID=`blkid | grep lv_root | awk '{print $3}' | cut -d '"' -f2` nowatchdog module_blacklist=iTCO_wdt" >> /boot/loader/entries/arch.conf

## if lv_swap exists
[ -d /dev/mapper/vg0-lv_swap ] && echo "options rd.luks.name=`blkid | grep crypto_LUKS | awk '{print $2}' | cut -d '"' -f2`=cryptlvm root=UUID=`blkid | grep lv_root | awk '{print $3}' | cut -d '"' -f2` rw resume=UUID=`blkid | grep lv_swap | awk '{print $3}' | cut -d '"' -f2` nowatchdog module_blacklist=iTCO_wdt" >> /boot/loader/entries/arch.conf

## long term support kernel (LTS)
echo 'title arch-lts' > /boot/loader/entries/arch-lts.conf
echo 'linux /vmlinuz-linux-lts' >> /boot/loader/entries/arch-lts.conf
echo 'initrd /initramfs-linux-lts.img' >> /boot/loader/entries/arch-lts.conf
[ ! -d /dev/mapper/vg0-lv_swap ] && echo "options rd.luks.name=`blkid | grep crypto_LUKS | awk '{print $2}' | cut -d '"' -f2`=cryptlvm root=UUID=`blkid | grep lv_root | awk '{print $3}' | cut -d '"' -f2` nowatchdog module_blacklist=iTCO_wdt" >> /boot/loader/entries/arch-lts.conf

## if lv_swap exists
[ -d /dev/mapper/vg0-lv_swap ] && echo "options rd.luks.name=`blkid | grep crypto_LUKS | awk '{print $2}' | cut -d '"' -f2`=cryptlvm root=UUID=`blkid | grep lv_root | awk '{print $3}' | cut -d '"' -f2` rw resume=UUID=`blkid | grep lv_swap | awk '{print $3}' | cut -d '"' -f2` nowatchdog module_blacklist=iTCO_wdt" >> /boot/loader/entries/arch-lts.conf


# generate initramfs with mkinitcpio

## for linux preset
mkinitcpio -p linux

## for linux-lts preset
mkinitcpio -p linux-lts


# add user

## set username

function set_username() {

	read -p "change username '$username'? (y/N) " -n 1 -r

	if [[ $REPLY =~ ^[Yy]$ ]] ; then
		echo
		printf "enter username: "
		read username
		echo
		printf "username '$username' entered, correct? (Y/n) \n"
		read username_correct

			if [[ $REPLY =~ ^[Nn]$ ]] ; then
				echo
				set_username
			else
				printf "using '$username' as username\n"
			fi
	else
		printf "using '$username' as username\n"
	fi

}

set_username

## add $username
useradd -m -g wheel $username

## add $username to video group (for brightnessctl)
usermod -a -G video $username

## set $username password
echo $username
passwd $username

## priviledge escalation for wheel group
sed -i 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers


# move /hajime to $user home
cp -r /hajime /home/$username
sudo rm -rf /hajime


# exit arch-chroot environment

## return to archiso environment
echo
echo 'exit'


# reboot advice
echo 'umount -R /mnt'
echo 'reboot'
echo 'sh hajime/3post.sh'


# finishing
touch /home/$username/hajime/2conf.done
