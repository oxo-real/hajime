#!/bin/bash
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
### (c) 2019 - 2020 cytopyge
###
##
#


# user customizable variables

timezone="Europe/Amsterdam"
sync_system_clock_over_ntp="true"
rtc_local_timezone="0"
arch_mirrorlist="https://www.archlinux.org/mirrorlist/?country=NL&protocol=http&protocol=https&ip_version=4"
mirror_country="Netherlands"
mirror_amount="5"
install_helpers="reflector"
to_pacstrap="base linux linux-firmware sudo dhcpcd lvm2 git binutils"

## recommended percentages of $lvm_size_calc
root_perc=0.01
home_perc=0.40
usr_perc=0.25
var_perc=0.25

## recommended SWAP size (GB)
swap_size_recomm=4.00


# define text appearance

## text color
RED='\033[0;31m' # red
GREEN='\033[0;32m' # green
NOC='\033[0m' # no color

## text style
UL=`tput smul`
NUL=`tput rmul`
BOLD=`tput bold`
NORMAL=`tput sgr0`

#terminus_font="terminus-font"
#console_font="ter-v16n"


# define reply functions

reply_plain() {

	# entry must be confirmed explicitly (by pushing enter)
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


# define exit function
exit_hajime () {

        echo
	echo
        printf " Hajime aborted by user!\n"
        echo
	sleep 1
	printf " Bye!\n"
	sleep 1
	clear
        exit

}


set_boot_device() {

	## lsblk for human
	lsblk -i --tree -o name,fstype,size,fsuse%,fsused,uuid,path,label,mountpoint
	echo


	## request boot device path
	printf "enter full path of the BOOT device (/dev/sdX): "
	reply_plain
	boot_dev=$reply

	echo
	printf "$(lsblk -i --tree -o name,fstype,size,fsuse%,fsused,uuid,path,label,mountpoint | grep "$boot_dev")\n"
	echo

	if [ "$boot_dev" == "$bootmnt_dev" ] ; then
	    echo
	    printf "invalid device path!\n"
	    printf "'$boot_dev' is current bootmnt\n"
	    printf "please try again"
	    sleep 4
	    clear
	    set_boot_device
	fi

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
	lsblk -i --tree -o name,fstype,size,fsuse%,fsused,uuid,path,label,mountpoint
	echo


	## request lvm device path
	printf "enter full path of the LVM device (/dev/sdY): "
	reply_plain
	lvm_dev=$reply

	if [ "$lvm_dev" == "$bootmnt_dev" ] ; then
	    echo
	    printf "invalid device path!\n"
	    printf "'$lvm_dev' is current bootmnt\n"
	    printf "please try again"
	    sleep 4
	    clear
	    set_boot_device
	fi

	echo
	printf "$(lsblk -i --tree -o name,fstype,size,fsuse%,fsused,uuid,path,label,mountpoint | grep "$lvm_dev")\n"
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
	lsblk -i --tree -o name,fstype,size,fsuse%,fsused,uuid,path,label,mountpoint
	echo

	printf "enter BOOT partition number: $boot_dev"
	reply_plain

	# boot partition is compulsory
	if [ -z "$reply" ]; then
	    printf "invalid partition number\n"
	    sleep 1
	    set_boot_partition
	fi

	boot_part_no=$reply
	boot_part=$boot_dev$boot_part_no

	echo
	printf "$(lsblk -i --tree -o name,fstype,size,fsuse%,fsused,uuid,path,label,mountpoint | grep $boot_dev)\n"
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
	lsblk -i --tree -o name,fstype,size,fsuse%,fsused,uuid,path,label,mountpoint
	echo

	printf "enter LVM partition number: $lvm_dev"
	reply_plain
	lvm_part_no=$reply
	lvm_part=$lvm_dev$lvm_part_no

	echo
	printf "$(lsblk -i --tree -o name,fstype,size,fsuse%,fsused,uuid,path,label,mountpoint | grep $lvm_dev)\n"
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
	lvm_size_calc=$(lsblk -o path,size | grep $lvm_part | awk '{print $2+0}')
	printf "size of the encrypted LVM volumegroup '$lvm_part' is $lvm_size_human\n"
	printf "logical volumes ROOT, HOME, USR & VAR are being created\n"
	echo

	## optional swap partition

	## starting dialog
	printf "create SWAP partition (y/N)? "
	reply_single_hidden
	swap_bool=$reply
	echo
	if printf "$reply" | grep -iq "^y" ; then
		printf "SWAP partition size (GB)? [$swap_size_recomm] "
		reply_plain
		swap_size_calc=0 #[TODO] necesarry?
		swap_size_calc=$reply
	        if [ -z "$swap_size_calc" ]; then
        	        swap_size_calc=$swap_size_recomm
        	fi
		### remove decimals
		swap_size="${swap_size_calc%%.*}"
		### correct $lvm_size_calc
		#lvm_size_calc="`echo "$lvm_size_calc - $swap_size" | bc`"
		lvm_size_calc=`echo - | awk "{$lvm_size_calc - $swap_size}"`
	else
		swap_size=0
		printf "SWAP partition will NOT be created\n"
	fi

	#root_size_calc=`echo "$root_perc * $lvm_size_calc" | bc`
	#home_size_calc=`echo "$home_perc * $lvm_size_calc" | bc`
	#usr_size_calc=`echo "$usr_perc * $lvm_size_calc" | bc`
	#var_size_calc=`echo "$var_perc * $lvm_size_calc" | bc`
	### calculate using awk (for posix compliance without bc)
	root_size_calc=`echo - | awk "{$root_perc * $lvm_size_calc}"`
	home_size_calc=`echo - | awk "{$home_perc * $lvm_size_calc}"`
	usr_size_calc=`echo - | awk  "{$usr_perc * $lvm_size_calc}"`
	var_size_calc=`echo - | awk  "{$var_perc * $lvm_size_calc}"`

	## ROOT partition
	echo
	printf "ROOT partition size (GB)? [$root_size_calc] "
	reply_plain
        if [ ! -z "$reply" ]; then
            #root_size_calc="`echo "$reply * 1" | bc`"
	    ### calculate using awk (for posix compliance without bc)
            root_size_calc="echo - | awk "{$reply * 1""
        fi
	### remove decimals
	root_size="${root_size_calc%%.*}"

	## HOME partition
	printf "HOME partition size (GB)? [$home_size_calc] "
	reply_plain
        if [ ! -z "$reply" ]; then
            #home_size_calc="`echo "$reply * 1" | bc`"
	    ### calculate using awk (for posix compliance without bc)
            home_size_calc=`echo - | awk "{$reply * 1}"`
        fi
	### remove decimals
	home_size="${home_size_calc%%.*}"

	## USR  partition
	printf "USR  partition size (GB)? [$usr_size_calc] "
	reply_plain
        if [ ! -z "$reply" ]; then
            #usr_size_calc="`echo "$reply * 1" | bc`"
	    ### calculate using awk (for posix compliance without bc)
            usr_size_calc=`echo - | awk "{$reply * 1}"`
        fi
	### remove decimals
	usr_size="${usr_size_calc%%.*}"

	## VAR  partition
	printf "VAR  partition size (GB)? [$var_size_calc] "
	#var_size_calc=0
	reply_plain
        if [ ! -z "$reply" ]; then
            #var_size_calc="`echo "$reply * 1" | bc`"
	    ### calculate using awk (for posix compliance without bc)
            var_size_calc=`echo - | awk "{$reply * 1}"`
        fi
	### remove decimals
	var_size="${var_size_calc%%.*}"

	## total
	#total_size_calc="`echo "$root_size + $home_size + $usr_size + $var_size + $swap_size" | bc`"
	#diff_total_lvm_calc="`echo "$total_size_calc - $lvm_size_calc" | bc`"
	### calculate using awk (for posix compliance without bc)
	total_size_calc=`echo - | awk "{$root_size + $home_size + $usr_size + $var_size + $swap_size}"`
	diff_total_lvm_calc=`echo - | awk "{$total_size_calc - $lvm_size_calc}"`
	diff_t="$(echo $diff_total_lvm_calc | awk -F . '{print $1}')"
	echo

	if [[ "$diff_t" -gt 0 ]]; then
		printf "disk size is insufficient for allocated space\n"
		printf "please shrink allocated space and try again\n"
		set_partition_sizes
	fi

	echo -n 'continue? (Y/n) '
	reply_single
	if printf "$reply" | grep -iq "^n" ; then
		exit_hajime
	else
		echo
		printf "encrypt partition and create lvm volumes\n"
		clear
	fi

}


# clear screen
clear
printf " hajime (c) 2019 - 2020 cytopyge\n"
echo
echo
printf " ${RED}CAUTION${NOC}\n"
printf " Hajime will install a bleeding edge arch linux operating system on this machine.\n"
echo
printf " Continuing will ${BOLD}overwrite existing data${NORMAL} on designated devices.\n"
printf " This software is subject to continuous development; \n"
printf " By entering 'y' or 'Y' below you will consent to the following:\n"
printf " This software is provided as is without warranty of any kind.\n"
printf " Continuing execution of this software is at your own risk.\n"
echo
printf " Be sure to have the most recent version of the arch installation image!\n"
printf " Use the 'isolatest' package to get the most recent authentic iso image.\n"
printf " You can download your copy via: ${UL}https://gitlab.com/cytopyge/isolatest${NUL}\n"
printf " Or retrieve an installation image via: ${UL}https://www/archlinux.org/download/${NUL}\n"
echo
printf " Are you sure to continue? (y/N) "


reply_single


if printf "$reply" | grep -iq "^y" ; then
	echo
	echo
	echo
	printf " Kamaete! "
	sleep 0.5
	printf "."
	sleep 0.5
	printf "."
	sleep 0.5
	printf "."
	sleep 1
	printf " Hajime! "
	sleep 1
	clear
else
    echo
    echo
    echo
    printf " Yame! "
	exit_hajime
fi


# get current bootmount blockdevice name
bootmnt_dev=$(mount | grep bootmnt | awk '{print $1}')


# network setup

## get network interface
i=$(ip -o -4 route show to default | awk '{print $5}')

## connect to network interface
dhcpcd $i
echo


# legible console font

## especially useful for hiDPI screens

## install terminus font
#pacman -Sy --noconfirm $terminus_font
#pacman -Ql $terminus_font

## set console font temporarily
#setfont $console_font


# for floating point arithmetic in this script

### calculate using awk (for posix compliance without bc)
#pacman -S --noconfirm bc


# hardware clock and system clock

## hardware clock (rtc) coordinated universal time (UTC)
timedatectl set-local-rtc $rtc_local_timezone
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


# setting up partitions

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
lvcreate -L "$usr_size"G vg0 -n lv_var
lvcreate -L "$var_size"G vg0 -n lv_usr

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


## create (optional) swap partition
if [[ $swap_bool == "Y" || $swap_bool == "y" ]]; then
	lvcreate -L "$swap_size"G vg0 -n lv_swap
	mkswap -L SWAP /dev/mapper/vg0-lv_swap
	swapon /dev/mapper/vg0-lv_swap
fi

# install helpers
clear
pacman -S --noconfirm $install_helpers


# configuring the mirrorlist

## backup old mirrorlist
cp /etc/pacman.d/mirrorlist /etc/pacman.d/`date "+%Y%m%d%H%M%S"`_mirrorlist_backup

## select fastest mirrors
reflector --verbose --country $mirror_country -l $mirror_amount --sort rate --save /etc/pacman.d/mirrorlist


# install base & base-devel package groups
pacstrap -i /mnt $to_pacstrap
#pacstrap -i /mnt base linux linux-firmware sudo dhcpcd lvm2 git binutils


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
clear
echo 'installing git and hajime to new environment'
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
