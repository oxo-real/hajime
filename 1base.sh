#!/usr/bin/env bash
#
##
###  _            _ _                  _
### | |__   __ _ (_|_)_ __ ___   ___  | |__   __ _ ___  ___
### | '_ \ / _` || | | '_ ` _ \ / _ \ | '_ \ / _` / __|/ _ \
### | | | | (_| || | | | | | | |  __/ | |_) | (_| \__ \  __/
### |_| |_|\__,_|/ |_|_| |_| |_|\___| |_.__/ \__,_|___/\___|1
###            |__/
###  _ _|_ _ ._    _  _
### (_\/|_(_)|_)\/(_|(/_
###   /      |  /  _|
###
### hajime_1base
### first part of a series
### cytopyge arch linux installation 'base'
### copyright (c) 2017 - 2022  |  cytopyge
###
### GNU GPLv3 GENERAL PUBLIC LICENSE
### This file is part of hajime.
###
### Hajime is free software: you can redistribute it and/or modify
### it under the terms of the GNU General Public License as published by
### the Free Software Foundation, either version 3 of the License, or
### (at your option) any later version.
###
### This program is distributed in the hope that it will be useful,
### but WITHOUT ANY WARRANTY; without even the implied warranty of
### MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
### GNU General Public License for more details.
###
### You should have received a copy of the GNU General Public License
### along with this program.  If not, see <https://www.gnu.org/licenses/>.
### https://www.gnu.org/licenses/gpl-3.0.txt
###
### y3l0b3b5z2u=:matrix.org @cytopyge@mastodon.social
###
##
#

## dependencies
#	archiso, REPO, 0init.sh

## usage
#	sh hajime/1base.sh

## example
#	none


# initial definitions

## script
script_name='1base.sh'
developer='cytopyge'
license='gplv3'
initial_release='2017'

## hardcoded variables

# user customizable variables
## offline installation
offline=1
# mountpoints set in 0init are unchanged

timezone="Europe/Stockholm"
sync_system_clock_over_ntp="true"
rtc_local_timezone="0"

arch_mirrorlist="https://archlinux.org/mirrorlist/?country=SE&protocol=https&ip_version=4&ip_version=6&use_mirror_status=on"
mirror_country="Sweden"
mirror_amount="5"

# 20220201 in the arch repository;
# base was a package group, but now is a package, while
# base-devel is (still) a package group
#
# base (package):
# --------------------------------
# bash bzip2 coreutils file filesystem findutils gawk gcc-libs gettext glibc
# grep gzip iproute2 iputils licenses pacman pciutils procps-ng psmisc sed shadow
# systemd systemd-sysvcompat tar util-linux xz linux (optional)
# https://github.com/archlinux/svntogit-packages/blob/master/base/repos/core-any/PKGBUILD
#
# base-devel (package-group):
# --------------------------------
# autoconf automake binutils bison fakeroot file findutils flex gawk gcc gettext
# grep groff gzip libtool m4 make pacman patch pkgconf sed sudo texinfo which
# https://archlinux.org/groups/x86_64/base-devel/
pkg_help="reflector"
pkg_core="base linux linux-firmware lvm2 dhcpcd git"
pkg_base_devel="$(pacman -Qg base-devel | sed 's/base-devel //g' | tr '\n' ' ')"


## recommended percentages of $lvm_size_calc
root_perc=0.01	## recommended minimum 1G
usr_perc=0.10	## recommended minimum 10G
var_perc=0.10	## recommended minimum 10G
home_perc=0.75

## boot size (MB)
boot_size=256

## recommended SWAP size (GB)
swap_size_recomm=4.00

## files
file_mnt_etc_fstab="/mnt/etc/fstab"


define_text_appearance()
{
	## text color
	MAGENTA='\033[0;35m'	# magenta
	GREEN='\033[0;32m'		# green
	RED='\033[0;31m'		# red
	NOC='\033[0m'			# no color

	## text style
	UL=`tput smul`			# underline
	NUL=`tput rmul`			# no underline
	BOLD=`tput bold`		# bold
	NORMAL=`tput sgr0`		# normal
}

#--------------------------------


# define reply functions

reply_plain()
{
	# entry must be confirmed explicitly (by pushing enter)
	read reply
}


reply_single()
{
    # first entered character goes directly to $reply
	stty_0=$(stty -g)
	stty raw #-echo
    reply=$(head -c 1)
    stty $stty_0
}


reply_single_hidden()
{
    # first entered character goes silently to $reply
	stty_0=$(stty -g)
	stty raw -echo
    reply=$(head -c 1)
	stty $stty_0
}


# define exit function
exit_hajime ()
{
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


get_bootmount()
{
	# get current bootmount blockdevice name
	bootmnt_dev=$(mount | grep bootmnt | awk '{print $1}')
}


network_setup()
{
	if [[ $offline -ne 1 ]]; then

		# network setup

		## get network interface
		i=$(ip -o -4 route show to default | awk '{print $5}')

		## connect to network interface
		dhcpcd $i
		echo

	fi
}


console_font()
{
	## especially useful for hiDPI screens on X

	## install terminus font
	pacman -S --noconfirm $terminus_font
	pacman -Ql $terminus_font

	## set console font temporarily
	setfont $console_font
}


clock()
{
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
	sleep 3
	clear
}



set_key_device()
{
	## usb device where detached luks header and keyfile will be stored

	## lsblk for human
	lsblk -i --tree -o name,fstype,uuid,path,size,fsuse%,fsused,label,mountpoint
	echo

	## request key device path
	printf "the KEY device has to be a physically detachable device\n"
	printf "this device will contain the luks header and keyfile\n"
	printf "enter full path of the KEY device (i.e. /dev/sdK): "
	reply_plain
	key_dev=$reply

	echo
	printf '%s\n' "$(lsblk -i --tree -o name,fstype,uuid,path,size,fsuse%,fsused,label,mountpoint | grep "$key_dev")"
	echo

	if [ "$key_dev" == "$bootmnt_dev" ] ; then
	    echo
	    printf "invalid device path!\n"
	    printf "'$key_dev' is current bootmnt\n"
	    printf "please try again"
	    sleep 4
	    clear
	    set_key_device
	fi

	printf "KEY device: '$key_dev', correct? (Y/n) "
	reply_single_hidden
	if printf "$reply" | grep -iq "^n" ; then
		clear
		set_key_device
	else
		echo
		echo
		printf "configure '$key_dev' as KEY device\n"
	fi

	## create key partition
	## info for human
	printf "add a new ${BOLD}8300${NORMAL} (Linux filesystem) partition\n"
	echo
	printf "<o>	create a new empty GUID partition table (GPT)\n"
	printf "<n>	add a new partition\n"
	printf "<w>	write table to disk and exit\n"
	printf "<q>	quit without saving changes\n"
	echo
	gdisk "$key_dev"
	clear
}


set_boot_device()
{
	## boot partition can be on its own separate device or
	## on its own (first) partition on the system device

	## lsblk for human
	lsblk -i --tree -o name,fstype,uuid,path,size,fsuse%,fsused,label,mountpoint
	echo


	## request boot device path
	printf "the BOOT device will contain the systemd-boot bootloader and\n"
	printf "the init ramdisk environment (initramfs) for booting the linux kernel\n"
	printf "enter full path of the BOOT device (i.e. /dev/sdB): "
	reply_plain
	boot_dev=$reply

	echo
	printf '%s\n' "$(lsblk -i --tree -o name,fstype,uuid,path,size,fsuse%,fsused,label,mountpoint | grep "$boot_dev")"
	echo

	if [ "$boot_dev" == "$bootmnt_dev" ] ; then
	    echo
	    printf "invalid device path!\n"
	    printf "'$boot_dev' is current bootmnt\n"
	    printf "please try again"
	    sleep 3
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
	printf "add a new ${BOLD}ef00${NORMAL} (EFI System) partition\n"
	echo
	printf "<o>	create a new empty GUID partition table (GPT)\n"
	printf "<n>	add a new partition\n"
	printf "<w>	write table to disk and exit\n"
	printf "<q>	quit without saving changes\n"
	echo
	gdisk "$boot_dev"
	clear
}


set_lvm_device()
{
	## LVM system partition installation target

	## lsblk for human
	lsblk -i --tree -o name,fstype,uuid,path,size,fsuse%,fsused,label,mountpoint
	echo


	## request lvm device path
	printf "on the LVM device the LVM partition will be created\n"
	printf "enter full path of the LVM device (i.e. /dev/sdL): "
	reply_plain
	lvm_dev=$reply

	if [ "$lvm_dev" == "$bootmnt_dev" ] ; then
	    echo
	    printf "invalid device path!\n"
	    printf "'$lvm_dev' is current bootmnt\n"
	    printf "please try again"
	    sleep 3
	    clear
	    set_boot_device
	fi

	echo
	printf '%s\n' "$(lsblk -i --tree -o name,fstype,uuid,path,size,fsuse%,fsused,label,mountpoint | grep "$lvm_dev")"
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
	printf "add a new ${BOLD}8e00${NORMAL} (Linux LVM) partition\n"
	echo
	printf "<o>	create a new empty GUID partition table (GPT)\n"
	printf "<n>	add a new partition\n"
	printf "<w>	write table to disk and exit\n"
	printf "<q>	quit without saving changes\n"
	echo
	gdisk "$lvm_dev"
	clear
}


set_key_partition()
{
	## dialog
	## lsblk for human
	clear
	lsblk -i --tree -o name,fstype,uuid,path,size,fsuse%,fsused,label,mountpoint
	echo

	printf "enter KEY partition number: $key_dev"
	reply_plain

	# usb partition is compulsory
	#if [ -z "$reply" ]; then
	#    printf "invalid partition number\n"
	#    sleep 1
	#    set_key_partition
	#fi

	key_part_no=$reply
	key_part=$key_dev$key_part_no

	echo
	printf '%s\n' "$(lsblk -i --tree -o name,fstype,uuid,path,size,fsuse%,fsused,label,mountpoint | grep $key_dev)"
	echo

	## check partition exists in lsblk
	if [ -z "$(lsblk -paf | grep -w $key_part)" ]; then
		printf "no valid partition, not found in lsblk\n"
		printf "please retry\n"
		sleep 1
		set_key_partition
	fi

	printf "the full KEY partition is: '$key_part', correct? (Y/n) "
	reply_single_hidden
	if printf "$reply" | grep -iq "^n" ; then
		clear
		set_key_partition
	else
		echo
		printf "using '$key_part' as KEY partition\n"
	fi

	echo
}


set_boot_partition()
{
	## dialog
	## lsblk for human
	clear
	lsblk -i --tree -o name,fstype,uuid,path,size,fsuse%,fsused,label,mountpoint
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
	printf '%s\n' "$(lsblk -i --tree -o name,fstype,uuid,path,size,fsuse%,fsused,label,mountpoint | grep "$boot_dev")"
	echo

	## check partition exists in lsblk
	if [ -z "$(lsblk -paf | grep -w $boot_part)" ]; then
		printf "no valid partition, not found in lsblk\n"
		printf "please retry\n"
		sleep 1
		set_boot_partition
	fi

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


set_lvm_partition()
{
	## dialog
	## lsblk for human
	clear
	lsblk -i --tree -o name,fstype,uuid,path,size,fsuse%,fsused,label,mountpoint
	echo

	printf "inside the LVM partition the LVM volumegroup will be created\n"
	printf "enter LVM partition number: $lvm_dev"
	reply_plain
	lvm_part_no=$reply
	lvm_part=$lvm_dev$lvm_part_no

	echo
	printf '%s\n' "$(lsblk -i --tree -o name,fstype,uuid,path,size,fsuse%,fsused,label,mountpoint | grep "$lvm_dev")"
	echo

	## check partition exists in lsblk
	if [ -z "$(lsblk -paf | grep -w $lvm_part)" ]; then
		printf "no valid partition, not found in lsblk\n"
		printf "please retry\n"
		sleep 1
		set_lvm_partition
	fi

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


set_lvm_partition_sizes()
{
	## lsblk for human
	clear
	lsblk -i --tree -o name,fstype,uuid,path,size,fsuse%,fsused,label,mountpoint
	echo

	lvm_size_bytes=$(lsblk -o path,size -b | grep $lvm_part | awk '{print $2}')
	lvm_size_human=$(lsblk -o path,size | grep $lvm_part | awk '{print $2}')
	lvm_size_calc=$(lsblk -o path,size | grep $lvm_part | awk '{print $2+0}')
	printf "size of the encrypted LVM volumegroup '$lvm_part' is $lvm_size_human\n"
	printf "logical volumes ROOT, USR, VAR & HOME are being created\n"
	echo

	## optional swap partition

	## starting dialog
	printf "create SWAP partition (Y/n)? "
	reply_single_hidden
	swap_bool=$reply
	echo

	if printf "$reply" | grep -iq "^n" ; then

		swap_size=0
		printf "SWAP partition will NOT be created\n"

	else

		printf "SWAP partition size (GB)? [$swap_size_recomm] "
		reply_plain
		swap_size_calc=$reply

		if [ -z "$swap_size_calc" ]; then

			swap_size_calc=$swap_size_recomm

		fi

		### remove decimals
		swap_size="${swap_size_calc%%.*}"

	fi

	# space_left is a running number
	# it decreases with every partition size chosen
	# space left after swap size chosen
	space_left=`echo - | awk "{print $lvm_size_calc - $swap_size}"`

	## calculate initial recommended sizes
	root_size_calc=`echo - | awk "{print $root_perc * $space_left}"`
	usr_size_calc=`echo - | awk  "{print $usr_perc * $space_left}"`
	var_size_calc=`echo - | awk  "{print $var_perc * $space_left}"`
	home_size_calc=`echo - | awk "{print $home_perc * $space_left}"`

	## ROOT partition
	printf "ROOT partition size {>=1G} (GB)? [$root_size_calc] "
	reply_plain

    if [ -n "$reply" ]; then

		root_size_calc=`echo - | awk "{print $reply * 1}"`
		### remove decimals
		root_size="${root_size_calc%%.*}"

	else

		### remove decimals
		root_size="${root_size_calc%%.*}"

    fi

	## recalculate
	### space left after root size chosen
	space_left=`echo - | awk "{print $space_left - $root_size}"`

	### percentages
	tot_perc=`echo - | awk "{print $usr_perc + $var_perc + $home_perc}"`

	usr_perc=`echo - | awk "{print $usr_perc / $tot_perc}"`
	var_perc=`echo - | awk "{print $var_perc / $tot_perc}"`
	home_perc=`echo - | awk "{print $home_perc / $tot_perc}"`

	### sizes
	usr_size_calc=`echo - | awk  "{print $usr_perc * $space_left}"`
	var_size_calc=`echo - | awk  "{print $var_perc * $space_left}"`
	home_size_calc=`echo - | awk "{print $home_perc * $space_left}"`

	printf "						ROOT set to "$root_size"GB ("$space_left"GB space left on "$lvm_part")\n"

	## USR  partition
	printf "USR  partition size {>=10G} (GB)? [$usr_size_calc] "
	reply_plain

	if [ -n "$reply" ]; then

		usr_size_calc=`echo - | awk "{print $reply * 1}"`
		### remove decimals
		usr_size="${usr_size_calc%%.*}"

	else

		### remove decimals
		usr_size="${usr_size_calc%%.*}"

	fi

	## recalculate
	### space left after usr size chosen
	space_left=`echo - | awk "{print $space_left - $usr_size}"`

	### percentages
	tot_perc=`echo - | awk "{print $var_perc + $home_perc}"`

	var_perc=`echo - | awk "{print $var_perc / $tot_perc}"`
	home_perc=`echo - | awk "{print $home_perc / $tot_perc}"`

	### sizes
	var_size_calc=`echo - | awk  "{print $var_perc * $space_left}"`
	home_size_calc=`echo - | awk "{print $home_perc * $space_left}"`

	printf "						USR  set to "$usr_size"GB ("$space_left"GB space left on "$lvm_part")\n"

	## VAR  partition
	printf "VAR  partition size {>=10G} (GB)? [$var_size_calc] "
	#var_size_calc=0
	reply_plain

    if [ -n "$reply" ]; then

		var_size_calc=`echo - | awk "{print $reply * 1}"`
		### remove decimals
		var_size="${var_size_calc%%.*}"

	else

		### remove decimals
		var_size="${var_size_calc%%.*}"

	fi

	## recalculate
	### space left after var size chosen
	space_left=`echo - | awk "{print $space_left - $var_size}"`

	### percentage
	tot_perc=`echo - | awk "{print $home_perc}"`

	home_perc=`echo - | awk "{print $home_perc / $tot_perc}"`

	### new size
	home_size_calc=`echo - | awk "{print $home_perc * $space_left}"`

	printf "						VAR  set to "$var_size"GB ("$space_left"GB space left on "$lvm_part")\n"

	## HOME partition
	printf "HOME partition size (GB)? [$home_size_calc] "
	reply_plain

    if [ -n "$reply" ]; then

        home_size_calc=`echo - | awk "{print $reply * 1}"`
		### remove decimals
		home_size="${home_size_calc%%.*}"

	else

		### remove decimals
		home_size="${home_size_calc%%.*}"

	fi

	## recalculate
	### space left after home size chosen
	space_left=`echo - | awk "{print $space_left - $home_size}"`

	printf "						HOME set to "$home_size"GB ("$space_left"GB space left on "$lvm_part")\n"

	## total
	total_size_calc=`echo - | awk "{print $swap_size + $root_size + $usr_size + $var_size + $home_size}"`
	diff_total_lvm_calc=`echo - | awk "{print $total_size_calc - $lvm_size_calc}"`
	diff_t="$(echo $diff_total_lvm_calc | awk -F . '{print $1}')"
	echo

	if [[ "$diff_t" -gt 0 ]]; then
		printf "disk size ("$lvm_size_human"GB) is insufficient for allocated space\n"
		printf "please shrink allocated space and try again\n"
		sleep 5
		clear
		set_lvm_partition_sizes
	fi

	printf "continue? (Y/n) "
	reply_single
	if printf "$reply" | grep -iq "^n" ; then
		exit_hajime
	else
		echo
		printf "encrypt partition and create lvm volumes\n"
	fi
}


legacy_cryptsetup()
{
	#cryptsetup on designated partition

	cryptsetup luksFormat --type luks2 "$lvm_part"
	cryptsetup open "$lvm_part" cryptlvm
}


cryptboot()
{
	## parameters
	cryptboot_hash="sha512"
	cryptboot_cipher="twofish-xts-plain64"
	cryptboot_keysize=512
	cryptboot_iter_msecs=6000	# secure minimum = 6000ms

	## create
	sudo cryptsetup \
		luksFormat \
		--hash=$cryptboot_hash \
		--cipher=$cryptboot_cipher \
		--key-size=$cryptboot_keysize \
		-i $cryptboot_iter_msecs \
		$boot_part
	# TODO boot_part prob dnw > boot_dev

	## open
	sudo cryptsetup open \
		$boot_part cryptboot
		## /dev/mapper/cryptboot

	## create ext2 fs in cryptboot
	sudo mkfs.ext2 /dev/mapper/cryptboot

	## mount cryptboot to /mnt
	sudo mount /dev/mapper/cryptboot /mnt

	cd /mnt
}


cryptkey()
{
	## create key file inside cryptboot (on key_device mounted on /mnt)
	# create crytpkey.img on key device for cryptkey

	keyimg_filesize="20M"
	keyimg_directory=""  #"$key_part"
	keyimg_filename="cryptkey.img"
	keyimg_file="$keyimg_directory/$keyimg_filename"

	sudo dd if=/dev/urandom of=$keyimg_file bs=$keyimg_filesize count=1

	## parameters
	keyimg_hash="sha512"
	keyimg_cipher="serpent-xts-plain64"
	keyimg_keysize="512"
	keyimg_iter_msecs="6000" 	# secure minimum = 6000ms

	## create
	## keyimg_file is nested inside cryptboot
	sudo cryptsetup \
		luksFormat \
		--hash=$keyimg_hash \
		--cipher=$keyimg_cipher \
		--key-size=$keyimg_keysize \
		-i $keyimg_iter_msecs \
		#--align-payload=1 \
		$keyimg_file

	## open
	cryptsetup open \
		$keyimg_filename cryptkey
		## /dev/mapper/cryptkey


	# create cryptkey header file header.img for cryptlvm on key device
	## inside cryptkey.img on key device

	##??## ##??## to create header.img inside cryptkey we need to mount cryptkey?
	## yes:
	#mkfs.ext4 -L O--, /dev/mapper/cryptkey
	#mkdir -p /mnt/cryptkey
	#mount /dev/mapper/cryptkey /mnt/cryptkey
	#cd /mnt/cryptkey

	truncate -s 2M header.img
}


cryptlvm()
{
	## parameters
	header_hash="sha512"
	header_cipher="serpent-xts-plain64"
	header_keysize="512"
	header_iter_msecs="6000" 	# secure minimum = 6000ms

	header_keyfile="/dev/mapper/cryptkey"
	header_keyfile_offset="512"
	header_keyfile_size="8192"
	header_align_payload="4096"
	header_image="header.img"

	## create
	cryptsetup \
		--hash=$header_hash \
		--cipher=$header_cipher \
		--key-size=$header_keysize \
		-i $header_iter_msecs \
		#--key-file=$header_keyfile \
		#--keyfile-offset=$header_keyfile_offset \
		#--keyfile-size=$header_keyfile_size \
		#--align-payload $header_align_payload \
		#--header $header_image \
		luksFormat $lvm_part

	## open
	cryptsetup open \
		#--header $header_image \
		#--key-file=$header_keyfile \
		#--keyfile-offset=$header_keyfile_offset \
		#--keyfile-size=$header_keyfile_size \
		$lvm_part cryptlvm
		## /dev/mapper/cryptlvm
}


create_lvm_volumes()
{
	## create physical volume with lvm
	pvcreate /dev/mapper/cryptlvm

	## create volumegroup 0 (vg0) with lvm
	vgcreate vg0 /dev/mapper/cryptlvm

	## create logical volumes
	lvcreate -L "$root_size"G vg0 -n lv_root
	lvcreate -L "$home_size"G vg0 -n lv_home
	lvcreate -L "$usr_size"G vg0 -n lv_var
	lvcreate -L "$var_size"G vg0 -n lv_usr
}


make_filesystems()
{
	mkfs.vfat -F 32 -n BOOT "$boot_part"
	mkfs.ext4 -L ROOT /dev/mapper/vg0-lv_root
	mkfs.ext4 -L HOME /dev/mapper/vg0-lv_home
	mkfs.ext4 -L USR /dev/mapper/vg0-lv_usr
	mkfs.ext4 -L VAR /dev/mapper/vg0-lv_var
}


create_mountpoints()
{
	mount /dev/mapper/vg0-lv_root /mnt
	mkdir /mnt/boot
	mkdir /mnt/home
	mkdir /mnt/usr
	mkdir /mnt/var
}


mount_partitions()
{
	mount "$boot_part" /mnt/boot
	mount /dev/mapper/vg0-lv_home /mnt/home
	mount /dev/mapper/vg0-lv_usr /mnt/usr
	mount /dev/mapper/vg0-lv_var /mnt/var
}


create_swap_partition()
{
	if [[ $swap_bool == "Y" || $swap_bool == "y" ]]; then
		lvcreate -L "$swap_size"G vg0 -n lv_swap
		mkswap -L SWAP /dev/mapper/vg0-lv_swap
		swapon /dev/mapper/vg0-lv_swap
	fi
}


install_helpers()
{
	if [[ $offline -ne 1 ]]; then

		## refresh package keys & install helpers
		#pacman-key --refresh-keys
		pacman -S --noconfirm $pkg_help

	fi
}


configure_mirrorlists()
{
	if [[ $offline -ne 1 ]]; then

		## backup old mirrorlist
		file_etc_pacmand_mirrorlist="/etc/pacman.d/mirrorlist"
		cp $file_etc_pacmand_mirrorlist /etc/pacman.d/`date "+%Y%m%d%H%M%S"`_mirrorlist_backup

		## select fastest mirrors
		reflector \
			--verbose \
			--country $mirror_country \
			-l $mirror_amount \
			--sort rate \
			--save $file_etc_pacmand_mirrorlist

	fi
}


install_base_devel_package_groups()
{
	packages="${pkg_core} ${pkg_base_devel}"
	pacstrap /mnt $packages
}


generate_fstab()
{
	# file system table
	genfstab -U -p /mnt >> $file_mnt_etc_fstab
}


modify_fstab()
{
	## fstab /usr entry with nopass 0
	sed -i '/\/usr/s/.$/0/' $file_mnt_etc_fstab

	## fstab /boot mount as ro
	sed -i '/\/boot/s/rw,/ro,/' $file_mnt_etc_fstab

	## fstab /usr mount as ro
	sed -i '/\/usr/s/rw,/ro,/' $file_mnt_etc_fstab
}


prepare_mnt_environment()
{
	echo 'installing hajime into the new environment'

	case $offline in

		1)
			# copy hajime to root (/hajime in conf)
			cp -prv /root/tmp/code/hajime /mnt

			cp -prv /root/tmp/code/hajime/misc/ol_pacman.conf /mnt/etc/pacman.conf

			;;

		*)
			# chroot changes the apparent root directory
			# commands will run isolated inside their root jail
			# here: /mnt will become the future root
			arch-chroot /mnt git clone https://gitlab.com/cytopyge/hajime
			;;

	esac

	echo
}


user_advice()
{
	echo 'now changing root'
	echo 'to continue execute:'
	echo
	echo 'sh hajime/2conf.sh'
	echo
}


finishing()
{
	arch-chroot /mnt touch hajime/1base.done
}


switch_to_installation_environment()
{
	# default bash will be ran inside the root jail
	arch-chroot /mnt
}


welcome()
{
	clear
	printf " hajime\n"
	printf " 2019 - 2022  |  cytopyge\n"
	echo
	echo
	printf " ${MAGENTA}CAUTION!${NOC}\n"
	printf " Hajime will install an Arch Linux operating system on this machine.\n"
	echo
	printf " By entering 'y/Y' you consent fully to the following:\n"
	printf " This software is provided 'as is' and without warranty of any kind.\n"
	printf " Continuing execution and usage of this software is ${BOLD}at own risk!${NORMAL}\n"
	printf " Opting out by entering 'n/N' and cancel the installation.\n"
	echo
	printf " Continuing will ${BOLD}overwrite existing data${NORMAL} on designated devices.\n"
	printf " This software is subject to continuous development, carefully consider its beta state. \n"

	printf " Be sure to have the most recent version of the arch installation media!\n"
	printf " Use the 'isolatest' package to get the most recent authentic iso image.\n"
	printf " You can download your copy via: ${UL}https://gitlab.com/cytopyge/isolatest${NUL}\n"
	printf " Or retrieve an installation image via: ${UL}https://www/archlinux.org/download/${NUL}\n"
	echo
	echo
	printf " Continue installation? (y/N) "

	reply_single

	if printf "$reply" | grep -iq "^y" ; then

		echo
		echo
		echo
		printf " Kamaete "
		sleep 0.5
		printf "."
		sleep 0.4
		printf "."
		sleep 0.3
		printf "."
		sleep 0.2
		printf " HAJIME! "
		sleep 1
		clear

	else

		echo
	    echo
	    echo
	    printf " YAME! "
		exit_hajime

	fi
}


main()
{
	define_text_appearance
	welcome
	get_bootmount
	network_setup
	#console_font
	clock
	## ##set_key_device
	set_boot_device
	set_lvm_device
	## ##set_key_partition
	set_boot_partition
	set_lvm_partition
	set_lvm_partition_sizes
	## ##cryptboot
	## ##cryptkey
	## ##cryptlvm
	legacy_cryptsetup
	create_lvm_volumes
	make_filesystems
	create_mountpoints
	mount_partitions
	create_swap_partition
	install_helpers
	configure_mirrorlists
	install_base_devel_package_groups
	generate_fstab
	modify_fstab
	prepare_mnt_environment
	user_advice
	finishing
	switch_to_installation_environment
}

main
