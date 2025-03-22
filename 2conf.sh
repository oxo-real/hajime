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
  sh hajime/2conf.sh [--offline|online|hybrid] [--config $custom_conf_file]

# example
  n/a

CAUTION 2conf.sh runs inside chroot jail (/mnt)

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

file_etc_locale_gen=/etc/locale.gen
file_etc_locale_conf=/etc/locale.conf
file_etc_vconsole_conf=/etc/vconsole.conf
file_etc_hosts=/etc/hosts
file_etc_hostname=/etc/hostname
file_etc_motd=/etc/motd
file_etc_sudoers=/etc/sudoers
file_etc_pacmand_mirrorlist=/etc/pacman.d/mirrorlist

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

## absolute file paths
hajime_src=/root/tmp/code/hajime
file_etc_pacman_conf=/etc/pacman.conf
file_root_bash_profile=/root/.bashrc

## CODE and REPO mountpoints
## we have no "$HOME"/dock/{2,3} yet
## therefore we use /root/tmp for the mountpoints
code_lbl=CODE
code_dir=/root/tmp/code
repo_lbl=REPO
repo_dir=/root/tmp/repo
repo_re=\/root\/tmp\/repo


#--------------------------------


args="$@"
getargs ()
{
    while :; do

	case "$1" in

	    -c | --config )
		shift

		## get config flag value
		cfv="$1"

		process_config_flag_value
		shift
		;;

	    --offline )
		## explicit arguments overrule defaults or configuration file setting

		## offline installation
		[[ "$1" =~ offline$ ]] && offline_arg=1 && online=0
		shift
		;;

	    --online )
		## explicit arguments overrule defaults or configuration file setting

		## online installation
		[[ "$1" =~ online$ ]] && online_arg=1 && online="$online_arg"
		shift
		;;

	    --hybrid )
		## explicit arguments overrule defaults or configuration file setting

		## hybrid installation
		[[ "$1" =~ hybrid$ ]] && online_arg=2 && online="$online_arg"
		shift
		;;

	    -- )
		shift

		## get config flag value
		cfv="$1"

		process_config_flag_value
		break
		;;

            * )
		break
		;;

	esac

    done
}


sourcing ()
{
    ## hajime exec location
    export script_name
    hajime_exec=/hajime

    ## configuration file
    ### define
    file_setup_config=$(head -n 1 "$hajime_exec"/setup/tempo-active.conf)
    ### source
    [[ -f "$file_setup_config" ]] && source "$file_setup_config"

    ## package list
    ### define
    file_setup_package_list="$hajime_exec"/setup/package.list
    ### source
    [[ -f "$file_setup_package_list" ]] && source "$file_setup_package_list"

    relative_file_paths

    ## config file is sourced; reevaluate explicit arguments
    explicit_arguments
}


relative_file_paths ()
{
    ## independent (i.e. no if) relative file paths
    file_pacman_offline_conf="$hajime_exec"/setup/pacman_offline.conf
    file_pacman_online_conf="$hajime_exec"/setup/pacman_online.conf
    file_pacman_hybrid_conf="$hajime_exec"/setup/pacman_hybrid.conf
}


explicit_arguments ()
{
    ## explicit arguments override default and configuration settings
    ## regarding network installation mode

    if [[ "$offline_arg" -eq 1 ]]; then
	## offine mode (forced)

	online=0

	## change network mode in configuration file
	## uncomment line online=0
	sed -i '/online=0/s/^[ \t]*#\+ *//' "$file_setup_config"
	## comment line online=1
	sed -i '/^online=1/ s/./#&/' "$file_setup_config"
	## comment line online=2
	sed -i '/^online=2/ s/./#&/' "$file_setup_config"

    elif [[ "$online_arg" -eq 1 ]]; then
	## online mode (forced)

	online=1

	## change network mode in configuration file
	## comment line online=0
	sed -i '/^online=0/ s/./#&/' "$file_setup_config"
	## uncomment line online=1
	sed -i '/online=1/s/^[ \t]*#\+ *//' "$file_setup_config"
	## comment line online=2
	sed -i '/^online=2/ s/./#&/' "$file_setup_config"

    elif [[ "$online_arg" -eq 2 ]]; then
	## hybrid mode (forced)

	online=2

	## change network mode in configuration file
	## comment line online=0
	sed -i '/^online=0/ s/./#&/' "$file_setup_config"
	## comment line online=1
	sed -i '/^online=1/ s/./#&/' "$file_setup_config"
	## uncomment line online=2
	sed -i '/online=2/s/^[ \t]*#\+ *//' "$file_setup_config"

    fi
}


process_config_flag_value ()
{
    realpath_cfv=$(realpath "$cfv")

    if [[ -f "$realpath_cfv" ]]; then

	file_setup_config="$realpath_cfv"
	printf '%s\n' "$file_setup_config" > "$file_setup_config_path"

    else

	printf 'ERROR config file ${st_bold}%s${st_def} not found\n' "$cfv"

	unset file_setup_config
	unset realpath_cfv
	unset cfv

	exit 151

    fi
}


installation_mode ()
{
    if [[ -n "$exec_mode" ]]; then
	## configuration file is being sourced

	file_setup_luks_pass="$hajime_exec"/setup/tempo-luks.pass
	file_setup_package_list="$hajime_exec"/setup/package.list

    fi

    if [[ "$online" -ne 0 ]]; then
	## online or hybrid mode

	## dhcp connect
	export hajime_exec
	sh hajime/0init.sh --pit 1

    fi
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
    ## privilege escalation for wheel group
    sed -i 's/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' $file_etc_sudoers

    ## keep environment variable with elevated privileges
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

    ucode="$cpu_type-ucode"
}


configure_pacman ()
{
    ## set correct pacman.conf

    case "$online" in

	0 )
	    ## offline mode
	    pm_alt_conf="$file_pacman_offline_conf"
	    ;;

	1 )
	    ## online mode
	    pm_alt_conf="$file_pacman_online_conf"
	    ;;

	2 )
	    ## hybrid mode
	    pm_alt_conf="$file_pacman_hybrid_conf"
	    ;;

    esac

    ## update offline repo dir
    sed -i "s#0init_repo_here#${repo_dir}#" "$pm_alt_conf"

    # init package keys
    pacman-key --config "$pm_alt_conf" --init

    # populate keys from archlinux.gpg
    pacman-key --config "$pm_alt_conf" --populate

    # update package database
    pacman --needed --noconfirm --config "$pm_alt_conf" -Syu
   # pacman -Syy
}


configure_mirrorlists ()
{
    if [[ $online -ne 0 ]]; then
	## online or hybrid mode

	## backup old mirrorlist
	file_etc_pacmand_mirrorlist="/etc/pacman.d/mirrorlist"
	cp --preserve --verbose "$file_etc_pacmand_mirrorlist" /etc/pacman.d/"$(date '+%Y%m%d_%H%M%S')"_mirrorlist_bu

	## select fastest mirrors
	reflector \
	    --verbose \
	    --country "$mirror_country" \
	    -l "$mirror_amount" \
	    --sort rate \
	    --save "$file_etc_pacmand_mirrorlist"

    fi
}


install_core ()
{
    # update repositories and install core applications
    # [Installation guide - ArchWiki]
    # (https://wiki.archlinux.org/title/Installation_guide#Install_essential_packages)
    pacman -S --needed --noconfirm --config "$pm_alt_conf" "${conf_pkgs[@]}"
}



install_bootloader ()
{
    # installing the EFI boot manager

    ## install boot files
    bootctl install

    ## configure boot loader
    printf "default arch\n" > $file_boot_loader_loader_conf
    printf "timeout $bootloader_timeout\n" >> $file_boot_loader_loader_conf
    printf "editor $bootloader_editor\n" >> $file_boot_loader_loader_conf
    printf "console-mode max" >> $file_boot_loader_loader_conf


    # adding boot loader entries

    ## linux kernel
    file_boot_loader_entries_arch_conf="/boot/loader/entries/arch.conf"
    echo 'title arch' > $file_boot_loader_entries_arch_conf
    echo 'linux /vmlinuz-linux' >> $file_boot_loader_entries_arch_conf
    echo "initrd /$ucode.img" >> $file_boot_loader_entries_arch_conf
    echo 'initrd /initramfs-linux.img' >> $file_boot_loader_entries_arch_conf

    ## linux long term support kernel (LTS)
    file_boot_loader_entries_arch_lts_conf="/boot/loader/entries/arch-lts.conf"
    echo 'title arch-lts' > $file_boot_loader_entries_arch_lts_conf
    echo 'linux /vmlinuz-linux-lts' >> $file_boot_loader_entries_arch_lts_conf
    echo "initrd /$ucode.img" >> $file_boot_loader_entries_arch_conf
    echo 'initrd /initramfs-linux-lts.img' >> $file_boot_loader_entries_arch_lts_conf


    # kernel options

    ## get parameter data
    blk_dev_list==$(lsblk --list --noheadings --output fstype,uuid,name)

    ## crypto_luks
    kp_luks_uuid=$(grep crypto_LUKS <<< "$blk_dev_list" | awk '{print $2}')
    kp_mapper_name=$(grep LVM2_member <<< "$blk_dev_list" | awk '{print $3}')

    ## root and swap
    kp_root_uuid=$(grep lv_root <<< "$blk_dev_list" | awk '{print $2}')
    kp_swap_uuid=$(grep lv_swap <<< "$blk_dev_list" | awk '{print $2}')

    ## additional options
    kp_no_watchdog='nowatchdog module_blacklist=iTCO_wd'
    kp_no_radios='rfkill.default_state=1'
    kp_added_options="$kp_no_watchdog $kp_no_radios"

    ## swap
    swap_exist=$(grep swap <<< "$blk_dev_list")

    case "$swap_exist" in

	swap )
	    ## lv_swap does exists
	    kp_options=$(printf 'options rd.luks.name=%s=%s root=UUID=%s rw resume=UUID=%s %s' \
				     "$kp_luks_uuid" \
				     "$kp_mapper_name" \
				     "$kp_root_uuid" \
				     "$kp_swap_uuid" \
				     "$kp_added_options"
			   )
	    ;;

	* )
	    ## lv_swap does not exist
	    kp_options=$(printf 'options rd.luks.name=%s=%s root=UUID=%s rw %s' \
				"$kp_luks_uuid" \
				"$kp_mapper_name" \
				"$kp_root_uuid" \
				"$kp_added_options"
		      )
	    ;;

    esac

    ## adding kernel options to the boot loader entries (ble and lts)
    printf '%s' "$kp_options" >> $file_boot_loader_entries_arch_conf
    printf '%s' "$kp_options" >> $file_boot_loader_entries_arch_lts_conf


    # generate initramfs with mkinitcpio

    ## create an initial ramdisk environment (initramfs)
    ## [mkinitcpio - ArchWiki](https://wiki.archlinux.org/title/Mkinitcpio#Common_hooks)
    ## [Installation guide - ArchWiki](https://wiki.archlinux.org/title/Installation_guide#Initramfs)
    ## enable systemd hooks
    sed -i "/^HOOKS/c\HOOKS=(base systemd microcode autodetect modconf keyboard sd-vconsole block sd-encrypt lvm2 filesystems fsck)" /etc/mkinitcpio.conf

    ## for linux preset
    mkinitcpio -p linux

    ## for linux-lts preset
    mkinitcpio -p linux-lts
}


move_hajime ()
{
    # move /hajime to $user home
    cp -r "$hajime_exec" /home/"$username"
    #cp -r /hajime /home/"$username"
    sudo rm -rf "$hajime_exec"
    #sudo rm -rf /hajime

    ## update configuration location for 3post
    sed -i 's#/hajime#\$HOME/hajime#' /home/"$username"/hajime/setup/tempo-active.conf
}


motd_3post ()
{
    ## motd will show up after system reboot and OS login
    echo > $file_etc_motd
    printf "# ${fg_magenta}connect CODE and REPO media${st_def}\n" >> $file_etc_motd
    echo '# then continue hajime Arch Linux installation with:' >> $file_etc_motd
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
    echo '# exit chroot jail (/mnt) and'
    echo '# return to the archiso environment with:'
    echo
    printf "${st_bold}exit${st_def}\n"
    echo
    echo '# umount all /mnt mountpoints:'
    echo
    printf "${st_bold}umount -R /mnt${st_def}\n"
    echo
    printf "# ${fg_magenta}remove ARCHISO, REPO and CODE${st_def} media,\n"
    echo '# then perform an initial autonomous system reboot:'
    echo
    printf "${st_bold}reboot${st_def}\n"
    echo
    printf '# after reboot, login as %s and continue with:\n' "$username"
    echo
    echo 'sh hajime/3post.sh'
    echo

    ## remove 2conf_bashrc
    ## NOTICE in 1base designated as file_mnt_root_bash_profile
    rm -rf "$file_root_bash_profile"

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
    get_offline_code
    time_settings
    locale_settings
    vconsole_settings
    set_hostname
    set_host_file
    pass_root
    add_user
    configure_pacman
    configure_mirrorlists
    #DEL_micro_code
    install_core
    install_bootloader
    move_hajime
    motd_3post
    exit_chroot_jail_mnt
}

main
