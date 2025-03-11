#! /usr/bin/env sh

###  _            _ _                                   __
### | |__   __ _ (_|_)_ __ ___   ___    ___ ___  _ __  / _|
### | '_ \ / _` || | | '_ ` _ \ / _ \  / __/ _ \| '_ \| |_
### | | | | (_| || | | | | | | |  __/ | (_| (_) | | | |  _|
### |_| |_|\__,_|/ |_|_| |_| |_|\___|  \___\___/|_| |_|_|  2
###            |__/
###
###  # # # # # #
###       #
###  # # # # # #
###

: '
hajime_2conf
second part of linux installation
copyright (c) 2017 - 2025  |  oxo

GNU GPLv3 GENERAL PUBLIC LICENSE
This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
https://www.gnu.org/licenses/gpl-3.0.txt

@oxo@qoto.org


# description
  second part of a series
  arch linux installation: configuration

# dependencies
  archiso, REPO, 0init.sh, 1base.sh

# usage
  sh hajime/2conf.sh [--online]

# example
  n/a

CAUTION 2conf runs inside chroot jail (/mnt)

# '


#set -o errexit
#set -o nounset
set -o pipefail

# initial definitions

## script
script_name=2conf.sh
developer=oxo
license=gplv3
initial_release=2017

## hardcoded variables
# user customizable variables

## file locations
file_boot_loader_loader_conf=/boot/loader/loader.conf
file_boot_loader_entries_arch_conf=/boot/loader/entries/arch.conf
file_boot_loader_entries_arch_lts_conf=/boot/loader/entries/arch-lts.conf

file_etc_pacman_conf=/etc/pacman.conf
file_etc_locale_gen=/etc/locale.gen
file_etc_locale_conf=/etc/locale.conf
file_etc_vconsole_conf=/etc/vconsole.conf
file_etc_hosts=/etc/hosts
file_etc_hostname=/etc/hostname
file_etc_motd=/etc/motd
file_etc_sudoers=/etc/sudoers
file_etc_pacmand_mirrorlist=/etc/pacman.d/mirrorlist

file_setup_config=/hajime/setup/dl3189.conf
file_setup_packages=/hajime/setup/package.list

## variable values
time_zone=Europe/CET
locale_conf=LANG=en_US.UTF-8
vconsole_conf=KEYMAP=us
mirror_country=Germany
mirror_amount=5
hostname_default=host
username_default=user
bootloader_timeout=2
bootloader_editor=0

#--------------------------------

sourcing ()
{
    export script_name
    ## configuration file
    #TODO DEV config file is now hardcoded
    [[ -f $file_setup_config ]] && source $file_setup_config

    ## sourcing conf_pkgs
    [[ -f $file_setup_packages ]] && source $file_setup_packages
}


args="$@"
getargs ()
{
    ## online installation
    [[ "$1" =~ online$ ]] && online=1
}


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


installation_mode ()
{
    ## online or offline mode
    if [[ $online -ne 1 ]]; then

	## CAUTION 2conf runs inside chroot jail (/mnt)
	## we have no ~/dock/2,3 yet
	## therefore we use /root/tmp for the mountpoints
	code_lbl=CODE
	code_dir=/root/tmp/code
	repo_lbl=REPO
	repo_dir=/root/tmp/repo
	repo_re=\/root\/tmp\/repo

	file_etc_pacman_conf=/etc/pacman.conf
	file_pacman_offline_conf=/root/hajime/setup/pacman_offline.conf

	# code_lbl=CODE
	# code_dir="/home/$(id -un)/dock/3"
	# repo_lbl=REPO
	# repo_dir="/home/$(id -un)/dock/2"
	# repo_re="\/home\/$(id -un)\/dock\/2"
	# file_etc_pacman_conf=/etc/pacman.conf

    elif [[ $online -eq 1 ]]; then

	file_pacman_online_conf="$code_dir"/hajime/setup/pacman_online.conf

    fi
}


reply ()
{
    # first silently entered character goes directly to $reply
    stty_0=$(stty -g)
    stty raw -echo
    reply=$(head -c 1)
    stty $stty_0
}


mount_repo ()
{
    repo_dev=$(lsblk -o label,path | grep "$repo_lbl" | awk '{print $2}')

    [[ -d $repo_dir ]] || mkdir -p "$repo_dir"

    mountpoint -q "$repo_dir"
    [[ $? -ne 0 ]] && sudo mount "$repo_dev" "$repo_dir"
}


get_offline_repo ()
{
    if [[ $online -ne 1 ]]; then

	mount_repo

	if [[ -z "$repo_dev" ]]; then

	    printf 'ERROR device REPO not found\n'
	    exit 20

	fi

    fi
}


mount_code ()
{
    code_dev=$(lsblk -o label,path | grep "$code_lbl" | awk '{print $2}')

    [[ -d $code_dir ]] || mkdir -p "$code_dir"

    mountpoint -q "$code_dir"
    [[ $? -ne 0 ]] && sudo mount "$code_dev" "$code_dir"
}


get_offline_code ()
{
    if [[ $online -ne 1 ]]; then

	mount_code

	if [[ -z "$code_dev" ]]; then

	    printf 'ERROR device CODE not found\n'
	    exit 30

	fi

    fi
}


pacman_conf_offline ()
{
    if [[ $online -ne 1 ]]; then

	## change SigLevel by adding PackageTrustAll to pacman.conf
	### this prevents errors on marginal trusted packages
	#sed -i 's/^SigLevel = Required DatabaseOptional/SigLevel = Required DatabaseOptional PackageTrustAll/' $file_etc_pacman_conf

	## redirect offline 'server' (file) location
	## define offline file location at the end of pacman.conf
	#TODO DEV sed gives an non-critical error: ''unknown option to s'
	## but seems to be working though
	sed -i "/^\[offline\]/{n;s/.*/Server = file:\/\/$repo_re/}" $file_etc_pacman_conf

	initialize_pacman
	echo

    fi
}


time_settings ()
{
    ## set time zone
    ln -sf /usr/share/zoneinfo/$time_zone /etc/localtime
    ## set hwclock
    hwclock --systohc
}


locale_settings ()
{
    # setting language, territory and codeset

    ## language
    ## [List of ISO 639 language codes - Wikipedia]
    ## (https://en.wikipedia.org/wiki/List_of_ISO_639_language_codes)

    ## territory
    ## [ISO 3166-1 - Wikipedia]
    ## (https://en.wikipedia.org/wiki/ISO_3166-1#Codes)

    ## codeset
    ## [Character encoding - Wikipedia]
    ## (https://en.wikipedia.org/wiki/Character_encoding#Unicode_encoding_model)

    sed -i "/^#en_US.UTF-8 UTF-8/c\en_US.UTF-8 UTF-8" $file_etc_locale_gen
    locale-gen
    echo $locale_conf > $file_etc_locale_conf
}


vconsole_settings ()
{
    echo $vconsole_conf > $file_etc_vconsole_conf
    echo
}


# network configuration

set_hostname ()
{
    if [[ -z $hostname ]]; then

	clear

	printf "hostname: '$hostname_default'\n"
	printf "correct? (y/N) "
	reply

	if printf "$reply" | grep -iq "^y" ; then

	    echo
	    printf "using '$hostname_default' as hostname\n"
	    printf "really sure? (Y/n) "
	    reply

	    if printf "$reply" | grep -iq "^n"; then

		clear
		set_hostname

	    else

		echo
		printf "using '$hostname_default' as hostname\n"

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

    fi
}


set_host_file ()
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
pass_root ()
{
    if [[ -n "$root_pw" ]]; then

	## password from config file
	printf '%s' "$root_pw" | passwd --stdin

    else

	## manual root password entry
	printf "$(whoami)@$hostname\n"
	passwd

    fi
}


## set username

set_username ()
{
    if [[ -z $username ]]; then

	clear
	printf "username: '$username_default'\n"
	printf "correct? (y/N) "
	reply

	if printf "$reply" | grep -iq "^y"; then

	    echo
	    printf "using '$username_default' as username\n"
	    printf "really sure? (Y/n) "
	    reply

	    if printf "$reply" | grep -iq "^n"; then

		clear
		set_username

	    else

		echo
		printf "using '$username_default' as username\n"

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

    fi
}


test_username ()
{
    username_length="$(printf "$username" | wc -c)"
    if [[ $username_length -gt 32 ]]; then

	printf "ERROR ${fg_magenta}$username${st_def} contains $username_length characters\n"
	printf "username may not exceed 32 characters\n"
	sleep 5
	set_username

    fi

    if [[ ! "$username" =~ ^[a-z_][a-z0-9_-]*[$]? ]]; then

	printf "ERROR ${fg_magenta}$username${st_def} not matching useradd criteria\n"
	printf "see useradd(8)\n"
	sleep 5
	set_username

    fi
}


add_username ()
{
    useradd --create-home --groups wheel $username
}


add_groups ()
{
    ## add $username to video group (for brightnessctl)
    usermod --append --groups video $username
}


set_passphrase ()
{
    ## set $username password

    if [[ -n "$username_pw" ]]; then

	## password from config file
	printf '%s' "$username_pw" | passwd --stdin $username

    else

	## manual user password entry
	printf "$(username)@$hostname\n"
	passwd $username

    fi
}


set_privileges ()
{
    ## priviledge escalation for wheel group
    sed -i 's/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' $file_etc_sudoers

    ## keep environment variable with elevated priviledges
    sed -i 's/# Defaults env_keep += "HOME"/Defaults env_keep += "HOME"\nDefaults !always_set_home, !set_home/' $file_etc_sudoers
}


# add user
add_user ()
{
    set_username
    add_username
    add_groups
    set_passphrase
    set_privileges
}


initialize_pacman ()
{
    pacman -Syy
}


install_helpers ()
{
    if [[ $online -eq 1 ]]; then

	# install helpers
	# clear
	# pacman -S --noconfirm $install_helpers


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
    fi
}


micro_code ()
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


install_core ()
{
    # update repositories and install core applications
    # [Installation guide - ArchWiki]
    # (https://wiki.archlinux.org/title/Installation_guide#Install_essential_packages)
    pacman -S --needed --noconfirm "${conf_pkgs[@]}"
}



install_bootloader ()
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

    ## [Installation guide - ArchWiki]
    ## (https://wiki.archlinux.org/title/Installation_guide#Initramfs)

    ## for linux preset
    mkinitcpio -p linux

    ## for linux-lts preset
    mkinitcpio -p linux-lts

    ## for all presets
    #mkinitcpio -P
}


move_hajime ()
{
    # move /hajime to $user home
    cp -r /hajime /home/$username
    sudo rm -rf /hajime
}


motd_3post ()
{
    echo > $file_etc_motd
    echo '# connect CODE and REPO media, then' >> $file_etc_motd
    echo '# continue hajime installation with:' >> $file_etc_motd
    echo >> $file_etc_motd
    printf "${st_bold}sh hajime/3post.sh${st_def}" >> $file_etc_motd
    echo >> $file_etc_motd
    echo >> $file_etc_motd
}

## no autostart because of reboot

exit_chroot_jail_mnt ()
{
    ## return to archiso environment
    echo
    echo '# exit chroot jail (/mnt)'
    echo '# return to the archiso environment with:'
    echo
    printf "${st_bold}exit${st_def}\n"
    printf "${st_bold}umount -R /mnt${st_def}\n"
    echo
    echo '# remove archiso, CODE and REPO media'
    echo '# to continue execute:'
    echo
    printf "${st_bold}reboot${st_def}\n"
    echo
    echo '# after reboot continue with:'
    echo
    echo 'sh hajime/3post.sh'
    echo

    # finishing
    touch /home/$username/hajime/2conf.done
}


main ()
{
    getargs $args
    sourcing
    define_text_appearance
    installation_mode
    get_offline_repo
    pacman_conf_offline
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
    motd_3post
    exit_chroot_jail_mnt
}

main
