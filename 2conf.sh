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


# time settings
## set time zone
ln -sf /usr/share/zoneinfo/Europe/Amsterdam /etc/localtime
## set hwclock
hwclock --systohc


# locale settings
sed -i "/^#en_US.UTF-8 UTF-8/c\en_US.UTF-8 UTF-8" /etc/locale.gen
locale-gen
echo 'LANG=en_US.UTF-8' > /etc/locale.conf


# network configuration

## create the hostname file
echo -n 'Enter hostname? '
read hostname
echo "$hostname" > /etc/hostname

## add matching entries to hosts file
echo '127.0.0.1    localhost.localdomain    localhost' >> /etc/hosts
echo '::1    localhost.localdomain    localhost' >> /etc/hosts
echo '127.0.1.1     "$hostname".localdomain     "$hostname"' >> /etc/hosts


# set console font permanent via sd-vconsole
echo 'FONT=ter-v32n' > /etc/vconsole.conf


# set root password
whoami
passwd


# update repositories and install core applications
pacman -Syu --noconfirm linux-headers linux-lts linux-lts-headers reflector wpa_supplicant wireless_tools openssh wl-clipboard vim


# configuring the mirrorlist

## update mirrorlist
https://www.archlinux.org/mirrorlist/all/

## backup old mirrorlist
cp /etc/pacman.d/mirrorlist /etc/pacman.d/`date "+%Y%m%d%H%M%S"`_mirrorlist.backup

## select fastest five
sudo reflector --verbose --country 'Netherlands' -l 5 --sort rate --save /etc/pacman.d/mirrorlist


# installing the EFI boot manager

## install boot files
bootctl install

## boot loader configuration
echo 'default arch' > /boot/loader/loader.conf
echo 'timeout 3' >> /boot/loader/loader.conf
echo 'editor 0' >> /boot/loader/loader.conf
echo 'console-mode max' >> /boot/loader/loader.conf


# configure mkinitcpio

## create an initial ramdisk environment (initramfs)
## enable systemd HOOKS
sed -i "/^HOOKS/c\HOOKS=(base systemd autodetect keyboard sd-vconsole modconf block sd-encrypt sd-lvm2 filesystems fsck)" /etc/mkinitcpio.conf


# adding boot loader entries

## bleeding edge kernel (BLE)
echo 'title Arch Linux BLE' > /boot/loader/entries/arch.conf
echo 'linux /vmlinuz-linux' >> /boot/loader/entries/arch.conf
echo 'initrd /initramfs-linux.img' >> /boot/loader/entries/arch.conf
[ ! -d /dev/mapper/vg0-lv_swap ] && echo "options rd.luks.name=`blkid | grep crypto_LUKS | awk '{print $2}' | cut -d '"' -f2`=cryptlvm root=UUID=`blkid | grep lv_root | awk '{print $3}' | cut -d '"' -f2` nowatchdog module_blacklist=iTCO_wdt" >> /boot/loader/entries/arch.conf
## if lv_swap exists
[ -d /dev/mapper/vg0-lv_swap ] && echo "options rd.luks.name=`blkid | grep crypto_LUKS | awk '{print $2}' | cut -d '"' -f2`=cryptlvm root=UUID=`blkid | grep lv_root | awk '{print $3}' | cut -d '"' -f2` rw resume=UUID=`blkid | grep lv_swap | awk '{print $3}' | cut -d '"' -f2` nowatchdog module_blacklist=iTCO_wdt" >> /boot/loader/entries/arch.conf

## long term support kernel (LTS)
echo 'title Arch Linux LTS' > /boot/loader/entries/arch-lts.conf
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

## add $username
echo 'enter username? '
read username
useradd -m -g wheel $username

## add $username to video group for brightness control
usermod -a -G video $username

## set $username password
passwd $username

## priviledge escalation for wheel group
sed -i 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers


# move /hajime to ~
cp -r /hajime /home/$username	
sudo rm -rf /hajime


# exit arch-chroot environment 

## return go archiso environment
echo 'manually:'
echo 'exit'
echo 'umount -R /mnt'
echo 'Remove boot medium'


# reboot advice
echo 'reboot'
echo 'sh hajime/3post.sh'


# finishing
touch /home/$username/hajime/2conf.done
