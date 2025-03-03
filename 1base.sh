#! /usr/bin/env sh

###  _            _ _                  _
### | |__   __ _ (_|_)_ __ ___   ___  | |__   __ _ ___  ___
### | '_ \ / _` || | | '_ ` _ \ / _ \ | '_ \ / _` / __|/ _ \
### | | | | (_| || | | | | | | |  __/ | |_) | (_| \__ \  __/
### |_| |_|\__,_|/ |_|_| |_| |_|\___| |_.__/ \__,_|___/\___|1
###            |__/
###
###  # # # # # #
###       #
###  # # # # # #
###

: '
hajime_1base
first part of linux installation
copyright (c) 2017 - 2025  |  oxo

GNU GPLv3 GENERAL PUBLIC LICENSE
This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICst_ulAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
https://www.gnu.org/licenses/gpl-3.0.txt

@oxo@qoto.org


# description
  first part of five scripts in total
  arch linux installation: base

# dependencies
  archiso, REPO, 0init.sh

# usage
  sh hajime/1base.sh [--online]

# example
  n/a

# '


#set -o errexit
#set -o nounset
set -o pipefail

# initial definitions

## script
script_name=1base.sh
developer=oxo
license=gplv3
initial_release=2017

## hardcoded variables

# user customizable variables

timezone=CET
sync_system_clock_over_ntp=true
rtc_local_timezone=0

arch_mirrorlist=https://archlinux.org/mirrorlist/?country=SE&protocol=https&ip_version=4&ip_version=6&use_mirror_status=on
mirror_country=Germany,Netherlands,Sweden,USA
mirror_amount=5
pkg_help=reflector  ## keeping base_packages clean
# [Installation guide - ArchWiki](https://wiki.archlinux.org/title/Installation_guide#Install_essential_packages)
# 20230212 https://archlinux.org/news/switch-to-the-base-devel-meta-package-requires-manual-intervention/
#pkg_core='base linux linux-firmware' (via install-packages)
#pkg_base_devel='base-devel' (via install-packages)

## boot size (MB)
boot_size=256
## recommended percentages of $lvm_size_calc
root_perc=0.05	## recommended minimum 1G
tmp_perc=0.02	## recommended minimum 1G
usr_perc=0.15	## recommended minimum 10G
var_perc=0.15	## recommended minimum 10G
home_perc=0.60
## recommended SWAP size (GB):
## with hibernation:
### swap_size_recomm => ram_size+sqrt(ram_size)
## without hibernation:
### ram_size  swap_size_recomm
###           min             max
###  <1GB     1*ram_size      2*ram_size
###  >1GB     sqrt(ram_size)  2*ram_size
swap_size_recomm=4.00

## files
file_hi_config=/root/hajime/install-config.sh
file_hi_config_1=/hajime/install-config.sh
file_hi_packages=/root/hajime/install-packages.sh
file_luks_pass=/root/tmp/code/hajime/luks_pass
file_mnt_etc_fstab=/mnt/etc/fstab


#--------------------------------


define_text_appearance()
{
    ## text color
    fg_magenta='\033[0;35m'	# magenta
    fg_green='\033[0;32m'	# green
    fg_red='\033[0;31m'		# red

    ## text style
    st_def='\033[0m'		# default
    st_ul=`tput smul`		# underline
    st_bold=`tput bold`		# bold
}


# define reply functions

reply_plain ()
{
    # entry must be confirmed explicitly (by pushing enter)
    read reply
}


reply_single ()
{
    # first entered character goes directly to $reply
    stty_0=$(stty -g)
    stty raw #-echo
    reply=$(head -c 1)
    stty $stty_0
}


reply_single_hidden ()
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
    exit
}


sourcing ()
{
    ## configuration file
    if [[ -f $file_hi_config ]]; then

	source $file_hi_config

    else

	source $file_hi_config_1

    fi

    ## sourcing base_pkgs
    [[ -f $file_hi_packages ]] && source $file_hi_packages
}


args="$@"
getargs ()
{
    ## online installation
    [[ "$1" =~ online$ ]] && online=1
}


offline_installation ()
{
    if [[ $online -ne 1 ]]; then

	## we have no ~/dock/2,3 yet
	## therefore we use /root/tmp for the mountpoints
	code_lbl=CODE
	code_dir=/root/tmp/code
	repo_lbl=REPO
	repo_dir=/root/tmp/repo
	repo_re=\/root\/tmp\/repo

	file_etc_pacman_conf=/etc/pacman.conf
	file_misc_pacman_conf="$code_dir"/hajime/misc/ol_pacman.conf

    fi
}


get_bootmount ()
{
    # get current bootmount blockdevice name
    #bootmnt_dev=$(mount | grep bootmnt | awk '{print $1}')
    # TODO
    # seems to be deprecated
    bootmnt_dev="deprecated"
}


get_lsblk ()
{
    lsblk --ascii --tree -o name,uuid,fstype,path,size,fsuse%,fsused,label,mountpoint
}


network_setup ()
{
    if [[ $online -eq 1 ]]; then

	# network setup

	## get network interface
	i=$(ip -o -4 route show to default | awk '{print $5}')

	## connect to network interface
	dhcpcd $i
	echo

    fi
}


console_font ()
{
    ## especially useful for hiDPI screens on X

    ## install terminus font
    pacman -S --noconfirm $terminus_font
    pacman -Ql $terminus_font

    ## set console font temporarily
    setfont $console_font
}


clock ()
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
}


set_key_device ()
{
    ## usb device where detached luks header and keyfile will be stored

    ## lsblk for human
    get_lsblk
    echo

    ## request key device path
    printf "the KEY device has to be a physically detachable device\n"
    printf "this device will contain the luks header and keyfile\n"
    printf "enter full path of the KEY device (i.e. /dev/sdK): "
    reply_plain
    key_dev=$reply

    echo

    printf '%s\n' "$(get_lsblk | grep "$key_dev")"
    #printf '%s\n' "$(lsblk --ascii --tree -o name,uuid,fstype,path,size,fsuse%,fsused,label,mountpoint | grep "$key_dev")"
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

    printf "KEY device: '$key_dev', correct? [Y/n] "
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
    printf "add a new ${st_bold}8300${st_def} (Linux filesystem) partition\n"
    echo
    printf "<o>	create a new empty GUID partition table (GPT)\n"
    printf "<n>	add a new partition\n"
    printf "<w>	write table to disk and exit\n"
    printf "<q>	quit without saving changes\n"
    echo
    gdisk "$key_dev"
    clear
}


set_boot_device ()
{
    ## boot partition can be on its own separate device or
    ## on its own (first) partition on the system device

    case $dev_boot in
	# dev_boot is used in configuration
	# boot_dev is for manual config

	'' )
	    ## manual config

	    ## lsblk for human
	    get_lsblk
	    echo

	    ## request boot device path
	    printf "the BOOT device will contain the systemd-boot bootloader and\n"
	    printf "the init ramdisk environment (initramfs) for booting the linux kernel\n"
	    echo
	    printf "enter full path of the BOOT ${st_bold}device${st_def} (i.e. /dev/sdB): "
	    reply_plain
	    boot_dev=$reply

	    echo
	    printf '%s\n' "$(get_lsblk | grep "$boot_dev")"
	    #printf '%s\n' "$(lsblk --ascii --tree -o name,uuid,fstype,path,size,fsuse%,fsused,label,mountpoint | grep "$boot_dev")"
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
	    printf "add a new ${st_bold}ef00${st_def} (EFI System) partition\n"
	    echo
	    printf "<o>	create a new empty GUID partition table (GPT)\n"
	    printf "<n>	add a new partition\n"
	    printf "<w>	write table to disk and exit\n"
	    printf "<q>	quit without saving changes\n"
	    echo
	    gdisk "$boot_dev"
	    clear
	    ;;

	* )
	    ## using configuration file
	    p_name=boot

	    if [[ -n $dev_boot_clear ]]; then

		printf "${st_bold}%s${st_def} ${fg_magenta}clear${st_def} partition and reset sector alignment\n" "$dev_boot"
		sgdisk --clear $dev_boot

	    fi

	    printf "${st_bold}%s${st_def} ${fg_magenta}write${st_def} partition data (%s)\n" "$dev_boot" "$p_name"
	    sgdisk --new $part_boot:0:${size_boot} --typecode $part_boot:$type_boot $dev_boot

	    boot_part=$dev_boot$part_boot
	    ;;

    esac

}


set_lvm_device ()
{
    ## LVM system partition installation target

    case $dev_lvm in
	# dev_lvm is used in configuration
	# lvm_dev is for manual config

	'' )

	    ## lsblk for human
	    get_lsblk
	    echo


	    ## request lvm device path
	    printf "on the LVM device the LVM partition will be created\n"
	    echo
	    printf "enter full path of the LVM ${st_bold}device${st_def} (i.e. /dev/sdL): "
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
	    printf '%s\n' "$(get_lsblk | grep "$lvm_dev")"
	    #printf '%s\n' "$(lsblk --ascii --tree -o name,uuid,fstype,path,size,fsuse%,fsused,label,mountpoint | grep "$lvm_dev")"
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
	    printf "add a new ${st_bold}8e00${st_def} (Linux LVM) partition\n"
	    echo
	    printf "<o>	create a new empty GUID partition table (GPT)\n"
	    printf "<n>	add a new partition\n"
	    printf "<w>	write table to disk and exit\n"
	    printf "<q>	quit without saving changes\n"
	    echo
	    gdisk "$lvm_dev"
	    clear
	    ;;

	* )
	    ## using configuration file
	    p_name=lvm

	    if [[ -n $dev_lvm_clear ]]; then

		printf "${st_bold}%s${st_def} ${fg_magenta}clear${st_def} partition and reset sector alignment\n" "$dev_lvm"
		sgdisk --clear $dev_lvm

	    fi

	    printf "${st_bold}%s${st_def} ${fg_magenta}write${st_def} partition data (%s)\n" "$dev_lvm" "$p_name"
	    sgdisk --new $part_lvm:0:$size_lvm --typecode $part_lvm:$type_lvm $dev_lvm

	    lvm_part=$dev_lvm$part_lvm
	    ;;

    esac
}


set_key_partition ()
{
    ## dialog
    ## lsblk for human
    clear
    get_lsblk
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
    printf '%s\n' "$(get_lsblk | grep $key_dev)"
    #printf '%s\n' "$(lsblk --ascii --tree -o name,uuid,fstype,path,size,fsuse%,fsused,label,mountpoint | grep $key_dev)"
    echo

    ## check partition exists in lsblk
    if [ -z "$(lsblk -paf | grep -w $key_part)" ]; then
	printf "partition not found in lsblk\n"
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


set_boot_partition ()
{
    if [[ -z $dev_boot ]]; then

	## dialog
	## lsblk for human
	clear
	get_lsblk
	echo

	printf "enter BOOT ${st_bold}partition${st_def} number: $boot_dev"
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
	printf '%s\n' "$(get_lsblk | grep "$boot_dev")"
	#printf '%s\n' "$(lsblk --ascii --tree -o name,uuid,fstype,path,size,fsuse%,fsused,label,mountpoint | grep "$boot_dev")"
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

    elif [[ -n $dev_boot ]]; then

	boot_part=$dev_boot$part_boot

    fi
}


set_lvm_partition ()
{
    if [[ -z $dev_lvm ]]; then

	## dialog
	## lsblk for human
	clear
	get_lsblk
	echo

	printf "inside the LVM partition the LVM volumegroup will be created\n"
	printf "enter LVM ${st_bold}partition${st_def} number: $lvm_dev"
	reply_plain
	lvm_part_no=$reply
	lvm_part=$lvm_dev$lvm_part_no

	echo
	printf '%s\n' "$(get_lsblk | grep "$lvm_dev")"
	#printf '%s\n' "$(lsblk --ascii --tree -o name,uuid,fstype,path,size,fsuse%,fsused,label,mountpoint | grep "$lvm_dev")"
	echo

	## check partition exists in lsblk
	if [ -z "$(lsblk -paf | grep -w $lvm_part)" ]; then
	    printf "partition not found in lsblk\n"
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

    elif [[ -n $dev_lvm ]]; then

	lvm_part=$dev_lvm$part_lvm

    fi
}


set_lvm_partition_sizes ()
{
    if [[ -z $dev_lvm ]]; then

	## lsblk for human
	clear
	get_lsblk
	echo

	lvm_size_bytes=$(lsblk -o path,size -b | grep $lvm_part | awk '{print $2}')
	lvm_size_human=$(lsblk -o path,size | grep $lvm_part | awk '{print $2}')
	lvm_size_calc=$(lsblk -o path,size | grep $lvm_part | awk '{print $2+0}')
	printf "size of the encrypted LVM volumegroup '$lvm_part' is $lvm_size_human\n"
	printf "logical volumes ROOT, TMP, USR, VAR & HOME are being created\n"
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
	tmp_size_calc=`echo - | awk  "{print $tmp_perc * $space_left}"`
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
	tot_perc=`echo - | awk "{print $tmp_perc + $usr_perc + $var_perc + $home_perc}"`

	tmp_perc=`echo - | awk "{print $tmp_perc / $tot_perc}"`
	usr_perc=`echo - | awk "{print $usr_perc / $tot_perc}"`
	var_perc=`echo - | awk "{print $var_perc / $tot_perc}"`
	home_perc=`echo - | awk "{print $home_perc / $tot_perc}"`

	### sizes
	tmp_size_calc=`echo - | awk  "{print $tmp_perc * $space_left}"`
	usr_size_calc=`echo - | awk  "{print $usr_perc * $space_left}"`
	var_size_calc=`echo - | awk  "{print $var_perc * $space_left}"`
	home_size_calc=`echo - | awk "{print $home_perc * $space_left}"`

	printf "						ROOT set to "$root_size"GB ("$space_left"GB space left on "$lvm_part")\n"

	## TMP  partition
	printf "TMP  partition size {>=1G} (GB)? [$usr_size_calc] "
	reply_plain

	if [ -n "$reply" ]; then

	    tmp_size_calc=`echo - | awk "{print $reply * 1}"`
	    ### remove decimals
	    tmp_size="${tmp_size_calc%%.*}"

	else

	    ### remove decimals
	    tmp_size="${tmp_size_calc%%.*}"

	fi

	## recalculate
	### space left after tmp size chosen
	space_left=`echo - | awk "{print $space_left - $tmp_size}"`

	### percentages
	tot_perc=`echo - | awk "{print $usr_perc + $var_perc + $home_perc}"`

	usr_perc=`echo - | awk "{print $usr_perc / $tot_perc}"`
	var_perc=`echo - | awk "{print $var_perc / $tot_perc}"`
	home_perc=`echo - | awk "{print $home_perc / $tot_perc}"`

	### sizes
	usr_size_calc=`echo - | awk  "{print $usr_perc * $space_left}"`
	var_size_calc=`echo - | awk  "{print $var_perc * $space_left}"`
	home_size_calc=`echo - | awk "{print $home_perc * $space_left}"`

	printf "						TMP  set to "$tmp_size"GB ("$space_left"GB space left on "$lvm_part")\n"

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
	total_size_calc=`echo - | awk "{print $swap_size + $root_size + $tmp_size + $usr_size + $var_size + $home_size}"`
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

    elif [[ -n $dev_lvm ]]; then

	root_size=$size_root
	home_size=$size_home
	tmp_size=$size_tmp
	usr_size=$size_usr
	var_size=$size_var

    fi
}


legacy_cryptsetup ()
{
    #cryptsetup on designated partition

    if [[ -n $luks_pass ]]; then
	## via configuration

	## write key-file
	printf '%s' "$luks_pass" > $file_luks_pass

	cryptsetup luksFormat --batch-mode --type luks2 --key-file $file_luks_pass "$lvm_part"
	cryptsetup --key-file $file_luks_pass open "$lvm_part" cryptlvm

	## remove key-file
	rm -rf $file_luks_pass

    elif [[ -z $luks_pass ]]; then
	## user interactive

	cryptsetup luksFormat --type luks2 "$lvm_part"
	cryptsetup open "$lvm_part" cryptlvm

    fi
}


cryptboot ()
{
    ## parameters
    cryptboot_hash="sha512"
    cryptboot_cipher="twofish-xts-plain64"
    cryptboot_keysize=512
    cryptboot_iter_msecs=6000  ## secure minimum = 6000ms

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


cryptkey ()
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


cryptlvm ()
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


create_lvm_volumes ()
{
    ## create physical volume with lvm
    pvcreate /dev/mapper/cryptlvm

    ## create volumegroup 0 (vg0) with lvm
    vgcreate vg0 /dev/mapper/cryptlvm

    ## create logical volumes
    lvcreate -L "$root_size"G vg0 -n lv_root
    lvcreate -L "$home_size"G vg0 -n lv_home
    lvcreate -L "$tmp_size"G vg0 -n lv_tmp
    lvcreate -L "$usr_size"G vg0 -n lv_var
    lvcreate -L "$var_size"G vg0 -n lv_usr
}


make_filesystems ()
{
    mkfs.vfat -F 32 -n BOOT "$boot_part"
    mkfs.ext4 -L ROOT /dev/mapper/vg0-lv_root
    mkfs.ext4 -L HOME /dev/mapper/vg0-lv_home
    mkfs.ext4 -L TMP /dev/mapper/vg0-lv_tmp
    mkfs.ext4 -L USR /dev/mapper/vg0-lv_usr
    mkfs.ext4 -L VAR /dev/mapper/vg0-lv_var
}


create_mountpoints ()
{
    mount /dev/mapper/vg0-lv_root /mnt
    mkdir /mnt/boot
    mkdir /mnt/home
    mkdir /mnt/tmp
    mkdir /mnt/usr
    mkdir /mnt/var
}


mount_partitions ()
{
    mount "$boot_part" /mnt/boot
    mount /dev/mapper/vg0-lv_home /mnt/home
    mount /dev/mapper/vg0-lv_tmp /mnt/tmp
    mount /dev/mapper/vg0-lv_usr /mnt/usr
    mount /dev/mapper/vg0-lv_var /mnt/var
}


create_swap_partition()
{
    ## yes from configuration
    if [[ $swap_bool == "Y" || $swap_bool == "y" || $swap_bool == "yes" ]]; then

	lvcreate -L "$swap_size"G vg0 -n lv_swap
	mkswap -L SWAP /dev/mapper/vg0-lv_swap

	swapon /dev/mapper/vg0-lv_swap

	echo

    fi
}


configure_pacman ()
{
    # [TODO] CHECK if pacman.conf is correct after 202306
    ## see: https://archlinux.org/news/git-migration-completed/

    if [[ $online -ne 1 ]]; then
	## configure pacman.conf for offline repository

	## copy pacman.conf
	cp --preserve --recursive --verbose "$file_misc_pacman_conf" "$file_etc_pacman_conf"

	## update pacman.conf
	sed -i "s#0init_repo_here#${repo_dir}#" "$file_etc_pacman_conf"

    fi

    ## change SigLevel by adding PackageTrustAll to pacman.conf
    ## this prevents errors on installing marginal trusted packages
    sed -i 's/^SigLevel = Required DatabaseOptional/SigLevel = Required DatabaseOptional PackageTrustAll/'  "$file_etc_pacman_conf"
    ## disable pacman signature check (not recommended)
    #sed -i 's/^SigLevel = Required DatabaseOptional/SigLevel = Never/' /etc/pacman.conf

    # init package keys
    pacman-key --init

    # populate keys from archlinux.gpg
    pacman-key --populate

    # update package database
    # pacman -Syy
}


install_helpers ()
{
    if [[ $online -eq 1 ]]; then

	## refresh package keys & install helpers
	#pacman-key --refresh-keys
	pacman -S --noconfirm $pkg_help

    fi
}


configure_mirrorlists ()
{
    if [[ $online -eq 1 ]]; then

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


install_base_devel_package_groups ()
{
    # -K initialize an empty pacman keyring in the target (implies -G).
    # see note/linux/arch/pacstrap or
    # https://man.archlinux.org/man/pacstrap.8
    # [FS#79619 : [systemd] 20-systemd-sysusers.hook fails to execute on a fresh system](https://bugs.archlinux.org/task/79619)
    # [[SOLVED] bootctl install: Bad file descriptor / Installation / Arch Linux Forums](https://bbs.archlinux.org/viewtopic.php?id=288660)
    pacstrap -K /mnt "${base_pkgs[@]}"
}


generate_fstab ()
{
    # file system table
    genfstab -U -p /mnt >> $file_mnt_etc_fstab
}


modify_fstab ()
{
    ## fstab /boot mount as ro
    sed -i '/\/boot/s/rw,/ro,/' $file_mnt_etc_fstab
    ## fstab /boot fmask and dmask 0077
    sed -i '/\/boot/s/fmask=0022/fmask=0077/' $file_mnt_etc_fstab
    sed -i '/\/boot/s/dmask=0022/dmask=0077/' $file_mnt_etc_fstab

    ## fstab /usr mount as ro
    sed -i '/\/usr/s/rw,/ro,/' $file_mnt_etc_fstab
    ## fstab /usr entry with nopass 0
    sed -i '/\/usr/s/.$/0/' $file_mnt_etc_fstab
}


prepare_mnt_environment ()
{
    echo 'copying hajime and pacman configuration into the new environment'

    case $online in

	1 )
	    # chroot changes the apparent root directory
	    # commands will run isolated inside their chroot jail
	    #TODO check for proper workings
	    # here: /mnt will become the / inside the chroot jail
	    #arch-chroot /mnt git clone https://codeberg.org/oxo/hajime.git
	    #arch-chroot /mnt /usr/bin/git clone https://codeberg.org/oxo/hajime
	    cd /mnt
	    git clone https://codeberg.org/oxo/hajime
	    cd
	    ;;

	* )
	    # copy hajime to chroot jail (/hajime in conf)
	    cp -prv /root/tmp/code/hajime /mnt
	    ;;

    esac

    # copy pacman.conf to root
    cp -prv /etc/pacman.conf /mnt/etc/pacman.conf

    echo
}


user_advice ()
{
    ## technically after arch-chroot /mnt
    echo '# exited archiso environment and'
    echo '# entered chroot jail (/mnt)'
    echo
    echo '# to continue execute:'
    echo
    printf "${st_bold}sh hajime/2conf.sh${st_def}\n"
    echo
}


finishing ()
{
    arch-chroot /mnt touch hajime/1base.done
}


enter_chroot_jail_mnt ()
{
    # default bash will be ran inside the chroot jail
    # [Linux Virtualization - Chroot Jail - GeeksforGeeks](https://www.geeksforgeeks.org/linux-virtualization-using-chroot-jail/)
    arch-chroot /mnt
}


autostart_next ()
{
    ## instead of autostart go to chroot jail

    #TODO DEV because arch-chroot there is a problem executing
    # commands after arch-chroot
    # below did not work
    ## triggered with configuration file
    # if [[ -n $after_1base ]]; then

    # 	arch-chroot /mnt sh /hajime/2conf.sh

    # fi
    #DEV
    arch-chroot /mnt "$code_dir"/code/hajime/2conf.sh
}


welcome ()
{
    clear
    printf 'hajime - %s\n' "$script_name"
    printf 'copyright (c) 2017 - 2025  |  oxo\n'
    echo
    echo
    printf "${st_bold}CAUTION!${st_def}\n"
    printf 'Hajime is about to install an Arch Linux operating system on this machine.\n'
    printf "${fg_magenta}Read the following carefully before you proceed!${st_def}\n"
    echo
    printf "This software is provided 'as is' and without warranty of any kind.\n"
    printf "Further execution and usage of this software is ${st_bold}at own risk!${st_def}\n"
    echo
    printf "Continuing will ${st_bold}erase all data${st_def} on designated devices.\n"
    printf 'Before proceeding, have restorable, up-to-date backups of all data.\n'
    echo
    printf 'This software is subject to continuous development.\n'
    printf 'Study and understand the code, while carefully consider its beta state.\n'
    printf 'When using a configuration file, verify the parameters are 100%% correct.\n'
    echo
    printf 'Be sure to have the most recent version of the arch installation media.\n'
    printf "Use the 'isolatest' package to get the most recent authentic iso image.\n"
    printf "You can download your copy via: ${st_ul}https://codeberg.org/oxo/isolatest${st_def}\n"
    printf "Or retrieve an installation image via: ${st_ul}https://www/archlinux.org/download/${st_def}\n"
    echo
    echo
    printf "Cancel the execution of this installation script by pressing 'N'.\n"
    echo
    printf "Manifest the intent to continue, while ${st_bold}fully consent${st_def}\n"
    printf "to the considerations above; press 'Y'.\n"
    echo
    echo
    printf "${fg_magenta}Continue installation?${st_def} [y/N] "

    reply_single

    if printf "$reply" | grep -iq "^y"; then

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


arch_install ()
{
    archinstall
}


main ()
{
    define_text_appearance
    welcome
    getargs $args
    sourcing
    offline_installation
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
    #arch_install
    configure_pacman
    install_helpers
    configure_mirrorlists
    install_base_devel_package_groups
    generate_fstab
    modify_fstab
    prepare_mnt_environment
    user_advice
    finishing
    enter_chroot_jail_mnt
    #autostart_next
}

main
