#!/bin/sh
#
##
###  _            _ _                  _
### | |__   __ _ (_|_)_ __ ___   ___  | |__   __ _ ___  ___
### | '_ \ / _` || | | '_ ` _ \ / _ \ | '_ \ / _` / __|/ _ \
### | | | | (_| || | | | | | | |  __/ | |_) | (_| \__ \  __/
### |_| |_|\__,_|/ |_|_| |_| |_|\___| |_.__/ \__,_|___/\___|1
###            |__/
###
###  _ _|_ _ ._    _  _
### (_\/|_(_)|_)\/(_|(/_
###   /      |  /  _|
###
### hajime_base
### cytopyge arch linux installation 'base'
### first part of a series
###
### (c) 2019 cytopyge
###
##
#


# user customizable variables
terminus_font="terminus-font"
console_font="ter-v20n"
timezone="Europe/Amsterdam"
sync_system_clock_over_ntp="true"
arch_mirrorlist="https://www.archlinux.org/mirrorlist/?country=NL&protocol=http&protocol=https&ip_version=4"
mirror_country="Netherlands"
mirror_amount="5"
install_helpers="reflector"


# clear screen
clear
echo
printf " Welcome to Hajime!\n"
echo
echo
printf " CAUTION!\n"
printf " These scripts will overwrite any existing data on target devices!\n"
printf " By continuing you will testify that you know what you are doing.\n"
echo
printf " Be sure to have the most recent version of the arch installation image!\n"
printf " Use cytopyge's 'isolatest' to get the most recent authentic iso image.\n"
printf " You can download it via: http://gitlab.com/cytopyge/isolatest\n"
printf " Or retrieve your installation image via: https://www/archlinux.org/download/\n"
echo
echo
printf " Are you really sure to continue? (y/N) "


# define reply functions

reply_plain() {

	# entery must be confirmed explicitly (by pushing enter)
	read reply

}


reply_single() {

        # first entered character goes directly to $reply
        stty_0=$(stty -g)
	stty raw #-echo
        reply=$(head -c 1)
        stty $stty_0

}


reply_single_hidden() {

        # first entered character goes silently to $reply
	stty_0=$(stty -g)
	stty raw -echo
        reply=$(head -c 1)
	stty $stty_0

}


reply_single


if printf "$reply" | grep -iq "^y" ; then
	echo
	echo
	printf " Have a safe journey!\n"
	sleep 2
	clear
else
        echo
	echo
        printf " Hajime aborted by user!\n"
        echo
	sleep 1
	printf " Bye!\n"
	echo
        exit
fi


# network setup

## get network interface
i=$(ip -o -4 route show to default | awk '{print $5}')

## connect to network interface
dhcpcd $i
echo


# legible console font
## especially useful for hiDPI screens

## install terminus font
pacman -Sy --noconfirm $terminus_font
pacman -Ql $terminus_font

## set console font temporarily
setfont $console_font


# for floating point arithmetic in this script
pacman -S --noconfirm bc


# hardware clock and system clock

## network time protocol
timedatectl set-ntp $sync_system_clock_over_ntp

## timezone
timedatectl set-timezone $timezone
## verify
date
hwclock -rv
timedatectl status
echo
clear


set_boot_device() {

## lsblk for human
lsblk -i --tree -o name,uuid,fstype,label,size,fsuse%,fsused,path,mountpoint
echo


## request boot device path
printf "enter full path of the BOOT device (/dev/sdX): "
reply_plain
boot_dev=$reply

echo
printf "$(lsblk -i --tree -o name,uuid,fstype,label,size,fsuse%,fsused,path,mountpoint | grep $boot_dev)\n"
echo

printf "BOOT device: '$boot_dev', correct? (Y/n) "
reply_single_hidden
if printf "$reply" | grep -iq "^n" ; then
	clear
	set_boot_device
else
	echo
	echo
	printf "configure '$boot_dev' as BOOT device\n"
fi

## create boot partition
## info for human
echo 'add a new ef00 (EFI System) partition'
echo
echo '<o>	create a new empty GUID partition table (GPT)'
echo '<n>	add a new partition'
echo '<w>	write table to disk and exit'
echo '<q>	quit without saving changes'
echo
gdisk "$boot_dev"
clear

}


set_lvm_device() {

## lsblk for human
lsblk -i --tree -o name,uuid,fstype,label,size,fsuse%,fsused,path,mountpoint
echo


## request lvm device path
printf "enter full path of the LVM device (/dev/sdY): "
reply_plain
lvm_dev=$reply

echo
printf "$(lsblk -i --tree -o name,uuid,fstype,label,size,fsuse%,fsused,path,mountpoint | grep $lvm_dev)\n"
echo

printf "LVM device: '$lvm_dev', correct? (Y/n) "
reply_single_hidden
if printf "$reply" | grep -iq "^n" ; then
	clear
	set_lvm_device
else
	echo
	echo
	printf "configure '$lvm_dev' as LVM device\n"
fi

## create lvm partition
## info for human
echo 'add a new 8e00 (Linux LVM) partition'
echo
echo '<o>	create a new empty GUID partition table (GPT)'
echo '<n>	add a new partition'
echo '<w>	write table to disk and exit'
echo '<q>	quit without saving changes'
echo
gdisk "$lvm_dev"
clear

}


set_boot_partition() {

	## dialog
	## lsblk for human
	clear
	lsblk -i --tree -o name,uuid,fstype,label,size,fsuse%,fsused,path,mountpoint
	echo

	printf "enter BOOT partition number: $boot_dev"
	reply_plain
	boot_part_no=$reply
	boot_part=$boot_dev$boot_part_no

	echo
	printf "$(lsblk -i --tree -o name,uuid,fstype,label,size,fsuse%,fsused,path,mountpoint | grep $boot_dev)\n"
	echo

	printf "the full BOOT partition is: '$boot_part', correct? (Y/n) "
	reply_single_hidden

	if printf "$reply" | grep -iq "^n" ; then
		clear
		set_boot_partition
	else
		echo
		printf "using '$boot_part' as BOOT partition\n"
	fi

	echo

}


set_lvm_partition() {

	## dialog
	## lsblk for human
	clear
	lsblk -i --tree -o name,uuid,fstype,label,size,fsuse%,fsused,path,mountpoint
	echo

	printf "enter LVM partition number: $lvm_dev"
	reply_plain
	lvm_part_no=$reply
	lvm_part=$lvm_dev$lvm_part_no

	echo
	printf "$(lsblk -i --tree -o name,uuid,fstype,label,size,fsuse%,fsused,path,mountpoint | grep $lvm_dev)\n"
	echo

	printf "the full LVM partition is: '$lvm_part', correct? (Y/n) "
	reply_single_hidden

	if printf "$reply" | grep -iq "^n" ; then
		clear
		set_lvm_partition
	else
		echo
		printf "using '$lvm_part' as LVM partition\n"
	fi

	echo

}


set_partition_sizes() {

	lvm_size_bytes=$(lsblk -o path,size -b | grep $lvm_part | awk '{print $2}')
	lvm_size_human=$(lsblk -o path,size | grep $lvm_part | awk '{print $2}')
	lvm_size_calc=$($lvm_size_human | rev | cut -c 2- | rev )
	printf "size of the encrypted LVM volumegroup '$lvm_part' is $lvm_size_human\n"
	printf "logical volumes ROOT, HOME, USR & VAR are being created\n"
	echo

	#recommended sizes
	#[TODO] calculate using awk (posix cmpliance without bc)
	root_perc="0.05"
	usr_perc="0.25"
	var_perc="0.25"
	home_perc="0.40"

	printf "01501005\n"
	root_size=`echo "$root_perc * $lvm_size_calc" | bc`
	usr_size=`echo "$usr_perc * $lvm_size_calc" | bc`
	var_size=`echo "$var_perc * $lvm_size_calc" | bc`
	home_size=`echo "$home_perc * $lvm_size_calc" | bc`

	printf "ROOT partition size [$root_size] (GB)? "
	root_size="0"
	reply_plain
        root_size=$reply
        if [ $root_size -eq "0" ]; then
                root_size="`echo "$root_perc * $lvm_size_calc" | bc`"
        fi

	printf "HOME partition size [$home_size] (GB)? "
	home_size="0"
	reply_plain
        home_size=$reply
        if [ $home_size -eq "0" ]; then
                home_size="`echo "$home_perc * $lvm_size_calc" | bc`"
        fi

	printf "USR  partition size [$usr_size] (GB)? "
	usr_size="0"
	reply_plain
	usr_size=$reply
        read usr_size
        if [ $usr_size -eq "0" ]; then
                usr_size="`echo "$usr_perc * $lvm_size_calc" | bc`"
        fi

	printf "VAR  partition size [$var_size] (GB)? "
	var_size="0"
	reply_plain
	var_size=$reply
        if [ $var_size -eq "0" ]; then
                var_size="`echo "$var_perc * $lvm_size_calc" | bc`"
        fi

	printf "create SWAP partition (y/N)? \n"
	reply_single_hidden
	swap_size=0
	if printf "$reply" | grep -iq "^y" ; then
		printf "SWAP partition size (GB)? \n"
		reply_plain
		swap_size=$reply
	else
		clear
	fi

	total_size="`echo "$root_size + $home_size + $var_size + $usr_size + $swap_size" | bc`"
	echo
	df -h
	echo
	echo "lvm partition "$lvm_part" has to be at least $total_size GB"
	echo -n 'continue? (Y/n) '
	read lvm_continue
	if [[ $lvm_continue == "Y" || $lvm_continue == "y" || $lvm_continue = "" ]]; then
	        # default option
		# lvm continue positive
		echo 'encrypt partition and create lvm volumes'
	else
		# lvm continue negative
		echo 'really exit? (y/N) '
		read lvm_continue_exit_confirm

		if [[ $lvm_continue_exit_confirm == "N" || $lvm_continue_exit_confirm == "n" || $lvm_continue_exit_confirm = "" ]]; then
			# default option
	        	# lvm exit confirmation negative
			# [TODO] do nothing
			:
		else
			# lvm exit confirmation positive
			echo 'exiting ...'
			#exit
		fi
	fi

}


set_boot_device
set_lvm_device
set_boot_partition
set_lvm_partition
set_partition_sizes


# cryptsetup on designated partition
cryptsetup luksFormat --type luks2 "$lvm_part"
cryptsetup open "$lvm_part" cryptlvm


# creating lvm volumes with lvm

## create physical volume with lvm
pvcreate /dev/mapper/cryptlvm

## create volumegroup vg0 with lvm
vgcreate vg0 /dev/mapper/cryptlvm

## create logical volumes
lvcreate -L "$root_size"G vg0 -n lv_root
lvcreate -L "$home_size"G vg0 -n lv_home
lvcreate -L "$var_size"G vg0 -n lv_usr
lvcreate -L "$usr_size"G vg0 -n lv_var

## make filesystems
mkfs.vfat -F 32 -n BOOT "$boot_part"
mkfs.ext4 -L ROOT /dev/mapper/vg0-lv_root
mkfs.ext4 -L HOME /dev/mapper/vg0-lv_home
mkfs.ext4 -L USR /dev/mapper/vg0-lv_usr
mkfs.ext4 -L VAR /dev/mapper/vg0-lv_var

## create mountpoints
mount /dev/mapper/vg0-lv_root /mnt
mkdir /mnt/boot
mkdir /mnt/home
mkdir /mnt/usr
mkdir /mnt/var

## mount partitions
mount "$boot_part" /mnt/boot
mount /dev/mapper/vg0-lv_home /mnt/home
mount /dev/mapper/vg0-lv_usr /mnt/usr
mount /dev/mapper/vg0-lv_var /mnt/var


## swap
if [[ $swap_bool == "Y" || $swap_bool == "y" ]]; then
	lvcreate -L "$swap_size"G vg0 -n lv_swap
	mkswap -L SWAP /dev/mapper/vg0-lv_swap
	swapon /dev/mapper/vg0-lv_swap
fi

# install helpers
pacman -S --noconfirm $install_helpers


# configuring the mirrorlist

## backup old mirrorlist
cp /etc/pacman.d/mirrorlist /etc/pacman.d/`date "+%Y%m%d%H%M%S"`_mirrorlist_backup

## select fastest mirrors
reflector --verbose --country $mirror_country -l $mirror_amount --sort rate --save /etc/pacman.d/mirrorlist


# install base & base-devel package group
pacstrap -i /mnt base base-devel


# generate fstab
genfstab -U -p /mnt >> /mnt/etc/fstab


# modify fstab

## fstab /usr entry with nopass 0
sed -i '/\/usr/s/.$/0/' /mnt/etc/fstab

## fstab /boot mount as ro
sed -i '/\/boot/s/rw,/ro,/' /mnt/etc/fstab

## fstab /usr mount as ro
sed -i '/\/usr/s/rw,/ro,/' /mnt/etc/fstab


# preparing /mnt environment
echo
echo 'installing git and hajime to new environment'
arch-chroot /mnt pacman -Sy --noconfirm git
arch-chroot /mnt git clone https://gitlab.com/cytopyge/hajime
echo


# user advice
echo 'changing root'
echo
echo 'to continue execute manually:'
echo 'sh hajime/2conf.sh'
echo


# finishing
arch-chroot /mnt touch hajime/1base.done

# switch to new installation environment
arch-chroot /mnt
