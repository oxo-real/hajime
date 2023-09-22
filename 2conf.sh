#! /usr/bin/env sh
set -o errexit
set -o nounset
set -o pipefail
#
##
###  _            _ _                                   __
### | |__   __ _ (_|_)_ __ ___   ___    ___ ___  _ __  / _|
### | '_ \ / _` || | | '_ ` _ \ / _ \  / __/ _ \| '_ \| |_
### | | | | (_| || | | | | | | |  __/ | (_| (_) | | | |  _|
### |_| |_|\__,_|/ |_|_| |_| |_|\___|  \___\___/|_| |_|_|  2
###            |__/
###  _    _
### (_)><(_)
###
### hajime_2conf
###
### second part of a series
### arch linux installation 'configuration'
### copyright (c) 2017 - 2023  |  oxo
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
### @oxo@qoto.org
###
##
#

## dependencies
#	archiso, REPO, 0init.sh, 1base.sh

## usage
#	cat header

## example
#	none


# initial definitions

## script
script_name='2conf.sh'
developer='oxo'
license='gplv3'
initial_release='2017'

## hardcoded variables
# user customizable variables

## offline installation
offline=1
code_dir='/tmp'
repo_dir='/repo'
repo_re='\/repo'

## file locations
file_etc_pacman_conf='/etc/pacman.conf'
file_etc_locale_gen="/etc/locale.gen"
file_etc_locale_conf="/etc/locale.conf"
file_etc_vconsole_conf="/etc/vconsole.conf"
file_etc_hosts="/etc/hosts"
file_etc_hostname="/etc/hostname"
file_etc_sudoers="/etc/sudoers"
file_etc_pacmand_mirrorlist="/etc/pacman.d/mirrorlist"
file_boot_loader_loader_conf="/boot/loader/loader.conf"
file_boot_loader_entries_arch_conf="/boot/loader/entries/arch.conf"
file_boot_loader_entries_arch_lts_conf="/boot/loader/entries/arch-lts.conf"

## variable values
time_zone="Europe/CET"
locale_conf="LANG=en_US.UTF-8"
vconsole_conf="KEYMAP=us"
mirror_country="Germany"
mirror_amount="5"
hostname="host"
username="user"
bootloader_timeout="2"
bootloader_editor="0"

## packages
linux_kernel="linux-headers"	#linux 1base
linux_lts_kernel="linux-lts linux-lts-headers"
# [Install Arch Linux on LVM - ArchWiki]
# (https://wiki.archlinux.org/title/Install_Arch_Linux_on_LVM#Adding_mkinitcpio_hooks)
# lvm2 is needed for lvm2 mkinitcpio hook
## [Fix missing libtinfo.so.5 library in Arch Linux]
## (https://jamezrin.name/fix-missing-libtinfo.so.5-library-in-arch-linux)
## prevent error that library libtinfo.so.5 couldn’t be found
core_applications='lvm2'
text_editor="emacs neovim"
install_helpers="reflector base-devel git"	#binutils 3post base-devel group
network='dhcpcd'
#network='dhcpcd systemd-networkd systemd-resolved'
network_wl="wpa_supplicant wireless_tools iw"
secure_connections="openssh"
system_security='' #nss-certs; comes with nss in core

#--------------------------------

temporary_maintenance()
{
    # DEV
    # libtinfo_so.5
    # rewiring for libtinfo.so.5 missing while 6 is installed
    ln -s /usr/lib/libcursesw.so.6 /usr/lib/libtinfo.so.5
    #ln -s /usr/lib/libtinfo.so.6 /usr/lib/libtinfo.so.5
}


reply()
{
    # first silently entered character goes directly to $reply
    stty_0=$(stty -g)
    stty raw -echo
    reply=$(head -c 1)
    stty $stty_0
}


mount_repo()
{
    repo_lbl='REPO'
    # 20230106 lsblk reports empty label names
    #repo_dev=$(lsblk -o label,path | grep "$repo_lbl" | awk '{print $2}')
    repo_dev=$(blkid | grep "$repo_lbl" | awk -F : '{print $1}')
    #local mountpoint=$(mount | grep $repo_dir)

    [[ -d $repo_dir ]] || mkdir -p "$repo_dir"

    sudo mount "$repo_dev" "$repo_dir"
    #[[ -n $mountpoint ]] || sudo mount "$repo_dev" "$repo_dir"
}


get_offline_repo()
{
    case $offline in
	1)
	    mount_repo
	    ;;
    esac
}


mount_code()
{
    code_lbl='CODE'
    code_dev=$(lsblk -o label,path | grep "$code_lbl" | awk '{print $2}')
    #local mountpoint=$(mount | grep $code_dir)

    [[ -d $code_dir ]] || mkdir -p "$code_dir"

    sudo mount "$code_dev" "$code_dir"
    #[[ -n $mountpoint ]] || sudo mount "$code_dev" "$code_dir"
}


get_offline_code()
{
    case $offline in
	1)
	    mount_code
	    ;;
    esac
}


reconfigure_pacman_conf()
{
    case $offline in
	1)
	    #### DEV now done in 1base
	    ## see also man pacman.conf

	    ## change SigLevel by adding PackageTrustAll to pacman.conf
	    ### this prevents errors on marginal trusted packages
	    #sed -i 's/^SigLevel = Required DatabaseOptional/SigLevel = Required DatabaseOptional PackageTrustAll/' $file_etc_pacman_conf

	    ## redirect offline 'server' (file) location
	    ## define offline file location at the end of pacman.conf
	    sed -i "/^\[offline\]/{n;s/.*/Server = file:\/\/$repo_re/}" $file_etc_pacman_conf

	    ##sed -i "s|\/root\/tmp\/repo|\/repo|" $file_etc_pacman_conf
	    #### DEV now done in 1base

	    pacman -Syy
	    echo
	    ;;
    esac
}


time_settings()
{
    ## set time zone
    ln -sf /usr/share/zoneinfo/$time_zone /etc/localtime
    ## set hwclock
    hwclock --systohc
}


locale_settings()
{
    sed -i "/^#en_US.UTF-8 UTF-8/c\en_US.UTF-8 UTF-8" $file_etc_locale_gen
    locale-gen
    echo $locale_conf > $file_etc_locale_conf
}


vconsole_settings()
{
    echo $vconsole_conf > $file_etc_vconsole_conf
    echo
}


# network configuration

set_hostname()
{
    clear

    printf "hostname: '$hostname'\n"
    printf "correct? (y/N) "
    reply

    if printf "$reply" | grep -iq "^y" ; then

	echo
	printf "using '$hostname' as hostname\n"
	printf "really sure? (Y/n) "
	reply

	if printf "$reply" | grep -iq "^n"; then

	    clear
	    set_hostname
	else
	    echo
	    printf "using '$hostname' as hostname\n"

	fi

    else

	echo
	read -p "enter hostname: " hostname
	printf "hostname:	'$hostname', correct? (Y/n) "
	reply

	if printf "$reply" | grep -iq "^n"; then

	    clear
	    set_hostname
	else
	    echo
	    printf "using '$hostname' as hostname\n"

	fi

    fi
    echo
}


set_host_file()
{
    ## create host file
    printf "$hostname" > $file_etc_hostname

    ## add matching entries to hosts file
    printf "127.0.0.1	localhost.localdomain	localhost\n" >> $file_etc_hosts
    printf "::1		localhost.localdomain	localhost\n" >> $file_etc_hosts
    printf "127.0.1.1	$hostname.localdomain	$hostname\n" >> $file_etc_hosts

    ## enable systemd-resolved
    #systemctl enable systemd-resolved.service
    ### symbolic link to the systemd stub, dns server will be set automaitcally
    #ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
    ### check resolving status
    #resolvectl status

    ## DNS over TLS (DOT)
    #mkdir /etc/systemd/resolve.conf.d
    #printf "[Resolve]" > /etc/systemd/resolve.conf.d/dns_over_tls.conf
    #printf "DNS=9.9.9.9#dns.quad9.net" >> /etc/systemd/resolve.conf.d/dns_over_tls.conf
    #printf "DNSOverTLS=yes" >> /etc/systemd/resolve.conf.d/dns_over_tls.conf
}


# set root password
pass_root()
{
    printf "$(whoami)@$hostname\n"
    passwd
}


## set username

set_username()
{
    clear
    printf "username: '$username'\n"
    printf "correct? (y/N) "
    reply

    if printf "$reply" | grep -iq "^y"; then

	echo
	printf "using '$username' as username\n"
	printf "really sure? (Y/n) "
	reply

	if printf "$reply" | grep -iq "^n"; then

	    clear
	    set_username

	else

	    echo
	    printf "using '$username' as username\n"

	fi

    else

	echo
	read -p "enter username: " username
	test_username
	printf "username: '$username', correct? (Y/n) "
	reply

	if printf "$reply" | grep -iq "^n"; then

	    clear
	    set_username

	else

	    echo
	    printf "using '$username' as username\n"

	fi

    fi
    echo
}


test_username() {
    username_length="$(printf "$username" | wc -c)"
    if [[ $username_length -gt 32 ]]; then

	printf "${MAGENTA}$username${NOC} contains $username_length characters\n"
	printf "usernames may only be up to 32 characters long\n"
	sleep 5
	set_username

    fi

    if [[ ! "$username" =~ ^[a-z_][a-z0-9_-]*[$]? ]]; then

	printf "${MAGENTA}$username${NOC} not matching useradd criteria\n"
	printf "see useradd(8)\n"
	sleep 5
	set_username

    fi
}


add_username()
{
    useradd -m -g wheel $username
}


add_groups()
{
    ## add $username to video group (for brightnessctl)
    usermod -a -G video $username
}


set_passphrase()
{
    ## set $username password
    printf "$username@$hostname\n"
    passwd $username
}


set_privileges()
{
    ## priviledge escalation for wheel group
    sed -i 's/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' $file_etc_sudoers

    ## keep environment variable with elevated priviledges
    sed -i 's/# Defaults env_keep += "HOME"/Defaults env_keep += "HOME"\nDefaults !always_set_home, !set_home/' $file_etc_sudoers
}


# add user
add_user()
{
    set_username
    add_username
    add_groups
    set_passphrase
    set_privileges
}


initialize_pacman()
{
    pacman -Syy
}


install_helpers()
{
    case $offline in

	1)
	;;

	*)

	    # install helpers
	    clear
	    pacman -S --noconfirm $install_helpers


	    # configuring the mirrorlist

	    ## backup old mirrorlist
	    cp $file_etc_pacmand_mirrorlist /etc/pacman.d/`date "+%Y%m%d%H%M%S"`_mirrorlist.backup

	    ## select fastest mirrors
	    reflector \
		--verbose \
		--country $mirror_country \
		-l $mirror_amount \
		--sort rate \
		--save $file_etc_pacmand_mirrorlist
	    ;;

    esac
}


micro_code()
{
    cpu_name=$(lscpu | grep 'Model name:' | awk '{print $3}')

    if [[ $cpu_name == 'AMD' ]]; then

	cpu_type='amd'
	pkg_ucode='amd-ucode'

    else

	cpu_type='intel'
	pkg_ucode='intel-ucode iucode-tool'

    fi

    #[TODO] check
    ucode="$cpu_type-ucode"
}


install_core()
{
    # update repositories and install core applications
    # [Installation guide - ArchWiki]
    # (https://wiki.archlinux.org/title/Installation_guide#Install_essential_packages)
    pacman -S --needed --noconfirm \
	   $pkg_ucode \
	   $linux_kernel \
	   $linux_lts_kernel \
	   $core_applications \
	   $text_editor \
	   $network \
	   $network_wl \
	   $secure_connections \
	   $system_security
}



install_bootloader()
{
    # installing the EFI boot manager

    ## install boot files
    bootctl install

    ## boot loader configuration
    printf "default arch\n" > $file_boot_loader_loader_conf
    printf "timeout $bootloader_timeout\n" >> $file_boot_loader_loader_conf
    printf "editor $bootloader_editor\n" >> $file_boot_loader_loader_conf
    printf "console-mode max" >> $file_boot_loader_loader_conf


    # create an initial ramdisk environment (initramfs)
    ## enable systemd hooks
    sed -i "/^HOOKS/c\HOOKS=(base systemd autodetect keyboard sd-vconsole modconf block sd-encrypt lvm2 filesystems fsck)" /etc/mkinitcpio.conf


    # adding boot loader entries

    ## linux kernel
    file_boot_loader_entries_arch_conf="/boot/loader/entries/arch.conf"
    echo 'title arch' > $file_boot_loader_entries_arch_conf
    echo 'linux /vmlinuz-linux' >> $file_boot_loader_entries_arch_conf
    echo "initrd /$ucode.img" >> $file_boot_loader_entries_arch_conf
    echo 'initrd /initramfs-linux.img' >> $file_boot_loader_entries_arch_conf
    ### if lv_swap does not exist
    [ ! -d /dev/mapper/vg0-lv_swap ] && echo "options rd.luks.name=`blkid | grep crypto_LUKS | awk '{print $2}' | cut -d '"' -f2`=cryptlvm root=UUID=`blkid | grep lv_root | awk '{print $3}' | cut -d '"' -f2` nowatchdog module_blacklist=iTCO_wdt" >> $file_boot_loader_entries_arch_conf
    ### if lv_swap does exists
    [ -d /dev/mapper/vg0-lv_swap ] && echo "options rd.luks.name=`blkid | grep crypto_LUKS | awk '{print $2}' | cut -d '"' -f2`=cryptlvm root=UUID=`blkid | grep lv_root | awk '{print $3}' | cut -d '"' -f2` rw resume=UUID=`blkid | grep lv_swap | awk '{print $3}' | cut -d '"' -f2` nowatchdog module_blacklist=iTCO_wdt" >> $file_boot_loader_entries_arch_conf

    ## linux long term support kernel (LTS)
    file_boot_loader_entries_arch_lts_conf="/boot/loader/entries/arch-lts.conf"
    echo 'title arch-lts' > $file_boot_loader_entries_arch_lts_conf
    echo 'linux /vmlinuz-linux-lts' >> $file_boot_loader_entries_arch_lts_conf
    echo "initrd /$ucode.img" >> $file_boot_loader_entries_arch_conf
    echo 'initrd /initramfs-linux-lts.img' >> $file_boot_loader_entries_arch_lts_conf
    ### if lv_swap does not exist
    [ ! -d /dev/mapper/vg0-lv_swap ] && echo "options rd.luks.name=`blkid | grep crypto_LUKS | awk '{print $2}' | cut -d '"' -f2`=cryptlvm root=UUID=`blkid | grep lv_root | awk '{print $3}' | cut -d '"' -f2` nowatchdog module_blacklist=iTCO_wdt" >> $file_boot_loader_entries_arch_lts_conf
    ### if lv_swap does exist
    [ -d /dev/mapper/vg0-lv_swap ] && echo "options rd.luks.name=`blkid | grep crypto_LUKS | awk '{print $2}' | cut -d '"' -f2`=cryptlvm root=UUID=`blkid | grep lv_root | awk '{print $3}' | cut -d '"' -f2` rw resume=UUID=`blkid | grep lv_swap | awk '{print $3}' | cut -d '"' -f2` nowatchdog module_blacklist=iTCO_wdt" >> $file_boot_loader_entries_arch_lts_conf


    # generate initramfs with mkinitcpio

    ## for linux preset
    mkinitcpio -p linux

    ## for linux-lts preset
    mkinitcpio -p linux-lts

    ## for all presets
    #mkinitcpio -P
}


move_hajime()
{
    # move /hajime to $user home
    cp -r /hajime /home/$username
    sudo rm -rf /hajime
}


exit_arch_chroot_mnt()
{
    ## return to archiso environment
    echo
    echo 'exit'
    # reboot advice
    echo 'umount -R /mnt'
    echo 'reboot'
    echo
    echo 'sh hajime/3post.sh'
    echo

    # finishing
    touch /home/$username/hajime/2conf.done
}


main()
{
    clear
    # DEV temporary_maintenance
    get_offline_repo
    reconfigure_pacman_conf
    time_settings
    locale_settings
    vconsole_settings
    set_hostname
    set_host_file
    pass_root
    add_user
    initialize_pacman
    install_helpers
    micro_code
    install_core
    install_bootloader
    move_hajime
    exit_arch_chroot_mnt
}

main
