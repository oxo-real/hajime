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
linux_kernel="linux-headers" #linux 1base
linux_lts_kernel="linux-lts linux-lts-headers"
command_line_editor="neovim"
install_helpers="reflector" #binutils 3post base-devel group
wireless="wpa_supplicant wireless_tools iw"
secure_connections="openssh"
micro_code_intel="intel-ucode iucode-tool"
micro_code_amd="amd-ucode"
system_security="arch-audit"


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
echo


reply() {

	# first silently entered character goes directly to $reply
	stty_0=$(stty -g)
	stty raw -echo
	reply=$(head -c 1)
	stty $stty_0

}


# network configuration

## set hostname

set_hostname() {

	clear
	printf "change hostname '$hostname'? (Y/n) "
	reply

	if printf "$reply" | grep -iq "^n" ; then
		echo
		printf "using '$hostname' as hostname\n"
	else
		echo
		read -p "enter hostname: " hostname

		printf "hostname:	'$hostname', correct? (Y/n) "
		reply

		if printf "$reply" | grep -iq "^n" ; then
			clear
			set_hostname
			else
				echo
				printf "using '$hostname' as hostname\n"
			fi
	fi
	echo

}

set_hostname

## create hostname file
printf "$hostname" > /etc/hostname

## add matching entries to hosts file
printf "127.0.0.1	localhost.localdomain	localhost\n" >> /etc/hosts
printf "::1		localhost.localdomain	localhost\n" >> /etc/hosts
printf "127.0.1.1	$hostname.localdomain	$hostname\n" >> /etc/hosts


# set root password
printf "$(whoami)@$hostname\n"
passwd


# add user

## set username

set_username() {

	clear
	read -p "change username '$username'? (Y/n) " -n 1 -r

	if [[ $REPLY =~ ^[Nn]$ ]] ; then
		echo
		printf "using '$username' as username\n"
	else
		echo
		read -p "enter username: " username
		read -p "username:	'$username', correct? (Y/n) " -n 1 -r

			if [[ $REPLY =~ ^[Nn]$ ]] ; then
				clear
				set_username
			else
				printf "using '$username' as username\n"
			fi
	fi
	echo

}

set_username

## add $username
useradd -m -g wheel $username

## add $username to video group (for brightnessctl)
usermod -a -G video $username

## set $username password
printf "$username@$hostname\n"
passwd $username

## priviledge escalation for wheel group
sed -i 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers




# install helpers
clear
pacman -Sy --noconfirm $install_helpers


# configuring the mirrorlist

## backup old mirrorlist
cp /etc/pacman.d/mirrorlist /etc/pacman.d/`date "+%Y%m%d%H%M%S"`_mirrorlist.backup

## select fastest mirrors
reflector --verbose --country $mirror_country -l $mirror_amount --sort rate --save /etc/pacman.d/mirrorlist


#[TODO]
# check if cpu_name contains "Intel"
#cpu_name=$(lscpu | grep name)
#if [[ $cpu_name == *"Intel"*  ]]; then
#	cpu_type="intel"
#	ucode="intel-ucode iucode-tool"
#else
#	#[TODO] proper check?
#	cpu_type="amd"
#	ucode="amd-ucode"
#fi


# update repositories and install core applications
pacman -S --noconfirm $linux_kernel $linux_lts_kernel $core_applications $command_line_editor $wireless $secure_connections $micro_code_intel $system_security


# installing the EFI boot manager

## install boot files
bootctl install

## boot loader configuration
printf "default arch\n" > /boot/loader/loader.conf
printf "timeout $bootloader_timeout\n" >> /boot/loader/loader.conf
printf "editor $bootloader_editor\n" >> /boot/loader/loader.conf
printf "console-mode max" >> /boot/loader/loader.conf


# create an initial ramdisk environment (initramfs)
## enable systemd hooks
sed -i "/^HOOKS/c\HOOKS=(base systemd autodetect keyboard sd-vconsole modconf block sd-encrypt sd-lvm2 filesystems fsck)" /etc/mkinitcpio.conf


# adding boot loader entries

## bleeding edge kernel
echo 'title arch' > /boot/loader/entries/arch.conf
echo 'linux /vmlinuz-linux' >> /boot/loader/entries/arch.conf
#[TODO] intel / amd check here
echo 'initrd /intel-ucode.img' >> /boot/loader/entries/arch.conf
echo 'initrd /initramfs-linux.img' >> /boot/loader/entries/arch.conf
### if lv_swap does not exist
[ ! -d /dev/mapper/vg0-lv_swap ] && echo "options rd.luks.name=`blkid | grep crypto_LUKS | awk '{print $2}' | cut -d '"' -f2`=cryptlvm root=UUID=`blkid | grep lv_root | awk '{print $3}' | cut -d '"' -f2` nowatchdog module_blacklist=iTCO_wdt" >> /boot/loader/entries/arch.conf
### if lv_swap does exists
[ -d /dev/mapper/vg0-lv_swap ] && echo "options rd.luks.name=`blkid | grep crypto_LUKS | awk '{print $2}' | cut -d '"' -f2`=cryptlvm root=UUID=`blkid | grep lv_root | awk '{print $3}' | cut -d '"' -f2` rw resume=UUID=`blkid | grep lv_swap | awk '{print $3}' | cut -d '"' -f2` nowatchdog module_blacklist=iTCO_wdt" >> /boot/loader/entries/arch.conf

## long term support kernel (LTS)
echo 'title arch-lts' > /boot/loader/entries/arch-lts.conf
echo 'linux /vmlinuz-linux-lts' >> /boot/loader/entries/arch-lts.conf
#[TODO] intel / amd check here
echo 'initrd /intel-ucode.img' >> /boot/loader/entries/arch.conf
echo 'initrd /initramfs-linux-lts.img' >> /boot/loader/entries/arch-lts.conf
### if lv_swap does not exist
[ ! -d /dev/mapper/vg0-lv_swap ] && echo "options rd.luks.name=`blkid | grep crypto_LUKS | awk '{print $2}' | cut -d '"' -f2`=cryptlvm root=UUID=`blkid | grep lv_root | awk '{print $3}' | cut -d '"' -f2` nowatchdog module_blacklist=iTCO_wdt" >> /boot/loader/entries/arch-lts.conf
### if lv_swap does exist
[ -d /dev/mapper/vg0-lv_swap ] && echo "options rd.luks.name=`blkid | grep crypto_LUKS | awk '{print $2}' | cut -d '"' -f2`=cryptlvm root=UUID=`blkid | grep lv_root | awk '{print $3}' | cut -d '"' -f2` rw resume=UUID=`blkid | grep lv_swap | awk '{print $3}' | cut -d '"' -f2` nowatchdog module_blacklist=iTCO_wdt" >> /boot/loader/entries/arch-lts.conf


# generate initramfs with mkinitcpio

## for linux preset
mkinitcpio -p linux

## for linux-lts preset
mkinitcpio -p linux-lts


# move /hajime to $user home
cp -r /hajime /home/$username
# TODO probably sudo has to be pacstrapped
sudo rm -rf /hajime


# exit arch-chroot environment

## return to archiso environment
echo
echo 'exit'


# reboot advice
echo 'umount -R /mnt'
echo 'reboot'
echo 'sh hajime/3post.sh'
echo


# finishing
touch /home/$username/hajime/2conf.done
