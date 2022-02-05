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
### (c) 2019 - 2022 cytopyge
###
##
#


# user customizable variables

## offline installation
offline=1
repo_dir='/repo'

## file locations
file_pacman_conf='/etc/pacman.conf'
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
time_zone="Europe/Stockholm"
locale_conf="LANG=en_US.UTF-8"
vconsole_conf="KEYMAP=us\nFONT=lat1-16"
mirror_country="Sweden"
mirror_amount="5"
hostname="host"
username="user"
bootloader_timeout="2"
bootloader_editor="0"

## packages
linux_kernel="linux-headers"	#linux 1base
linux_lts_kernel="linux-lts linux-lts-headers"
text_editor="emacs neovim"
install_helpers="reflector"		#binutils 3post base-devel group
wireless="wpa_supplicant wireless_tools iw"
secure_connections="openssh"
micro_code_intel="intel-ucode iucode-tool"
micro_code_amd="amd-ucode"
system_security="arch-audit"


clear


reply()
{
	# first silently entered character goes directly to $reply
	stty_0=$(stty -g)
	stty raw -echo
	reply=$(head -c 1)
	stty $stty_0
}


time_settings()
{
	## set time zone
	ln -sf /usr/share/zoneinfo/$time_zone /etc/localtime
	## set hwclock
	hwclock --systohc
}

time_settings


locale_settings()
{
	sed -i "/^#en_US.UTF-8 UTF-8/c\en_US.UTF-8 UTF-8" $file_etc_locale_gen
	locale-gen
	echo $locale_conf > $file_etc_locale_conf
}


#[TODO] vconsole is not written
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

set_hostname


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

set_host_file


# set root password
pass_root()
{
	printf "$(whoami)@$hostname\n"
	passwd
}

pass_root


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


add_username()
{
	#[TODO] user is not in sudoers file!!
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
	sed -i 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' $file_etc_sudoers

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

add_user


reconfigure_pacman_conf()
{
	sed -i 's|root\/tmp\/repo|repo|' $file_pacman_conf
}

reconfigure_pacman_conf


mount_repo()
{
	repo_lbl='REPO'
	repo_dev=$(lsblk -o label,path | grep "$repo_lbl" | awk '{print $2}')

	[[ -d $repo_dir ]] || mkdir -p "$repo_dir"

	mount "$repo_dev" "$repo_dir"
}

mount_repo


initialize_pacman()
{
	pacman -Sy
}

initialize_pacman


install_helpers()
{
	case offline in

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

install_helpers



ucode()
{
	#[TODO]
	## check if cpu_name contains "Intel"
	cpu_name=$(lscpu | grep name)
	if [[ $cpu_name == *"Intel"*  ]]; then
		cpu_type="intel"
		ucode="intel-ucode iucode-tool"
	else
		#[TODO] proper check?
		cpu_type="amd"
		ucode="amd-ucode"
	fi
}


install_core()
{
	# update repositories and install core applications
	pacman -S --needed --noconfirm \
		$linux_kernel \
		$linux_lts_kernel \
		$core_applications \
		$text_editor \
		$wireless \
		$secure_connections \
		$micro_code_intel \
		$system_security
}

install_core


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
	#sed -i "/^HOOKS/c\HOOKS=(base systemd autodetect keyboard sd-vconsole modconf block sd-encrypt sd-lvm2 filesystems fsck)" /etc/mkinitcpio.conf


	# adding boot loader entries

	## bleeding edge kernel

	echo 'title arch' > $file_boot_loader_entries_arch_conf
	echo 'linux /vmlinuz-linux' >> $file_boot_loader_entries_arch_conf
	#[TODO] intel / amd check here
	echo 'initrd /intel-ucode.img' >> $file_boot_loader_entries_arch_conf
	echo 'initrd /initramfs-linux.img' >> $file_boot_loader_entries_arch_conf
	### if lv_swap does not exist
	[ ! -d /dev/mapper/vg0-lv_swap ] && echo "options rd.luks.name=`blkid | grep crypto_LUKS | awk '{print $2}' | cut -d '"' -f2`=cryptlvm root=UUID=`blkid | grep lv_root | awk '{print $3}' | cut -d '"' -f2` nowatchdog module_blacklist=iTCO_wdt" >> $file_boot_loader_entries_arch_conf
	### if lv_swap does exists
	[ -d /dev/mapper/vg0-lv_swap ] && echo "options rd.luks.name=`blkid | grep crypto_LUKS | awk '{print $2}' | cut -d '"' -f2`=cryptlvm root=UUID=`blkid | grep lv_root | awk '{print $3}' | cut -d '"' -f2` rw resume=UUID=`blkid | grep lv_swap | awk '{print $3}' | cut -d '"' -f2` nowatchdog module_blacklist=iTCO_wdt" >> $file_boot_loader_entries_arch_conf

	## long term support kernel (LTS)

	echo 'title arch-lts' > $file_boot_loader_entries_arch_lts_conf
	echo 'linux /vmlinuz-linux-lts' >> $file_boot_loader_entries_arch_lts_conf
	#[TODO] intel / amd check here
	echo 'initrd /intel-ucode.img' >> $file_boot_loader_entries_arch_lts_conf
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
}

install_bootloader


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
echo


# finishing
touch /home/$username/hajime/2conf.done
