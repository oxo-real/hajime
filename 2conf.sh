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
command_line_editor="emacs neovim"
install_helpers="reflector" #binutils 3post base-devel group
wireless="wpa_supplicant wireless_tools iw"
secure_connections="openssh"
micro_code_intel="intel-ucode iucode-tool"
micro_code_amd="amd-ucode"
system_security="arch-audit"
crypto="cryptboot sbupdate-git"


reply() {

	# first silently entered character goes directly to $reply
	stty_0=$(stty -g)
	stty raw -echo
	reply=$(head -c 1)
	stty $stty_0

}


set_time() {

	## set time zone
	ln -sf /usr/share/zoneinfo/$time_zone /etc/localtime
	## set hwclock
	hwclock --systohc

}


set_locale() {

	file_etc_locale_gen="/etc/locale.gen"
	file_etc_locale_conf="/etc/locale.conf"

	sed -i "/^#en_US.UTF-8 UTF-8/c\en_US.UTF-8 UTF-8" $file_etc_locale_gen
	locale-gen
	echo $locale_conf > $etc_locale_conf

}


set_vconsole() {

	file_etc_vconsole_conf="/etc/vconsole.conf"
	echo $vconsole_conf > $file_etc_vconsole_conf
	echo

}


set_hostname() {

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


create_hostname_file() {

	file_etc_hostname="/etc/hostname"
	printf "$hostname" > $file_etc_hostname

	## add matching entries to hosts file
	file_etc_hosts="/etc/hosts"
	printf "127.0.0.1	localhost.localdomain	localhost\n" >> $file_etc_hosts
	printf "::1		localhost.localdomain	localhost\n" >> $file_etc_hosts
	printf "127.0.1.1	$hostname.localdomain	$hostname\n" >> $file_etc_hosts

}


enable_systemd_resolved() {

	systemctl enable systemd-resolved.service
	## symbolic link to the systemd stub, dns server will be set automaitcally
	ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
	## check resolving status
	resolvectl status

	# DNS over TLS (DOT)
	mkdir /etc/systemd/resolve.conf.d
	printf "[Resolve]" > /etc/systemd/resolve.conf.d/dns_over_tls.conf
	printf "DNS=9.9.9.9#dns.quad9.net" >> /etc/systemd/resolve.conf.d/dns_over_tls.conf
	printf "DNSOverTLS=yes" >> /etc/systemd/resolve.conf.d/dns_over_tls.conf

}


root_password() {

	printf "$(whoami)@$hostname\n"
	passwd

}


user_name() {

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


user_add(){

	useradd -m -g wheel $username

}


user_groups() {

	## video for brightnessctl
	usermod -a -G video $username
	## add more groups here
	#usermod -a -G group $username

}


user_password() {

	printf "$username@$hostname\n"
	passwd $username

}


wheel_privilege_escalation() {

	file_etc_sudoers="/etc/sudoers"
	sed -i 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' $file_etc_sudoers

	## keep environment variable with elevated priviledges
	sed -i 's/# Defaults env_keep += "HOME"/Defaults env_keep += "HOME"\nDefaults !always_set_home, !set_home/' $file_etc_sudoers

}


install_helpers() {

	pacman -Sy --noconfirm $install_helpers

}


mirrorlist_configuration() {

	file_etc_pacmand_mirrorlist="/etc/pacman.d/mirrorlist"

	## backup old mirrorlist
	cp $file_etc_pacmand_mirrorlist /etc/pacman.d/`date "+%Y%m%d%H%M%S"`_mirrorlist.backup

	## select fastest mirrors
	reflector --verbose --country $mirror_country -l $mirror_amount --sort rate --save $file_etc_pacmand_mirrorlist

}


micro_code() {

	cpu_name=$(lscpu | grep name | awk '{print $2}')

	if [[ -n $($cpu_name | grep -i intel) ]]; then

		cpu_type="intel"

	elif [[ -n $($cpu_name | grep -i amd) ]]; then

		cpu_type="amd"

	fi

}


install_core_applications() {

	pacman -S --noconfirm \
		$linux_kernel \
		$linux_lts_kernel \
		$core_applications \
		$command_line_editor \
		$wireless \
		$secure_connections \
		$micro_code$cpu_type \
		$system_security \
		$crypto
	#TODO ucode

}


install_boot_files() {

	bootctl install

}


configure_boot_loader() {

	file_boot_loader_loader_conf="/boot/loader/loader.conf"

	printf "default arch\n" > $file_boot_loader_loader_conf
	printf "timeout $bootloader_timeout\n" >> $file_boot_loader_loader_conf
	printf "editor $bootloader_editor\n" >> $file_boot_loader_loader_conf
	printf "console-mode max" >> $file_boot_loader_loader_conf

}


create_initramfs() {

	# create an initial ramdisk environment (initramfs)
	## enable systemd hooks
	sed -i "/^HOOKS/c\HOOKS=(base systemd autodetect keyboard sd-vconsole modconf block sd-encrypt sd-lvm2 filesystems fsck)" /etc/mkinitcpio.conf

}


create_initramfs_crypto() {

	# create an initial ramdisk environment (initramfs)
	## enable systemd hooks
	sed -i "/^MODULES/c\MODULES=(loop)" /etc/mkinitcpio.conf
	sed -i "/^HOOKS/c\HOOKS=(base systemd autodetect keyboard sd-vconsole modconf block cenchook sd-encrypt sd-lvm2 filesystems fsck)" /etc/mkinitcpio.conf

}


more_crypto() {

	# create custom encrypt hook for mkinitcpio
	## this is ugly! repair later
	## files ought to be generated in 1base
	$key_part=$(cat keypart.tmp) && rm keypart.tmp
	$lvm_part=$(cat lvmpart.tmp) && rm lvmpart.tmp


	#TODO remove in production version (if this is in master branch)
	cd ~/hajime
	git checkout det_header
	cd

	$cenchook_directory="/etc/initcpio/hooks/"
	$cenchook_filename="cenchook"
	$cenchook_file=$cenchook_directory$cenchook_filename
	cp ~/hajime/cenchook $cenchook_file

	## retrieve ids
	lsblk -paf | grep -v '/dev/loop'
	ls -l /dev/disk/by-id
	keydevid=$(ls -l /dev/disk/by-id | grep $key_part) | awk '{print $9}'
	lvmdevid=$(ls -l /dev/disk/by-id | grep $lvm_part) | awk '{print $9}'
	printf "$keydevid -> ../..$key_part\n"
	printf "$lvmdevid -> ../..$lvm_part\n"

	## edit cenchook
	sed -i '/keydevid/'$keydevid'/' $cenchook_file
	sed -i '/lvmdevid/'$lvmdevid'/' $cenchook_file

	## crypttab
	printf "cryptboot $keydevid none luks" >> /etc/crypttab

	## cryptboot.conf
	printf "BOOT_CRYPT_NAME="cryptboot"" >> /etc/cryptboot.conf
	printf "BOOT_DIR="/boot"" >> /etc/cryptboot.conf
	printf "EFI_DIR="/boot/efi"" >> /etc/cryptboot.conf
	printf "EFI_KEYS_DIR="/boot/efikeys"" >> /etc/cryptboot.conf


	## efikeys
	cryptboot-efikeys create
	cryptboot-efikeys enroll

	cd /boot/efikeys
	rename db DB db.*


	printf "KEY_DIR="/boot/efikeys"" >> /etc/default/sbupdate
	printf "ESP_DIR="/boot/efi"" >> /etc/default/sbupdate
	printf "CMDLINE_DEFAULT="/vmlinuz-linux root=/dev/mapper/store-root rw quiet"" >> /etc/default/sbupdate

}


boot_loader_entry_ble_kernel() {

	file_boot_loader_entries_arch_conf="/boot/loader/entries/arch.conf"

	echo 'title arch' > $file_boot_loader_entries_arch_conf
	echo 'linux /vmlinuz-linux' >> $file_boot_loader_entries_arch_conf
	#[TODO] intel / amd check here
	echo 'initrd /intel-ucode.img' >> $file_boot_loader_entries_arch_conf
	echo 'initrd /initramfs-linux.img' >> $file_boot_loader_entries_arch_conf
	### if lv_swap does not exist
	[ ! -d /dev/mapper/vg0-lv_swap ] && echo "options rd.luks.name=`blkid | grep crypto_LUKS | awk '{print $2}' | cut -d '"' -f2`=cryptlvm root=UUID=`blkid | grep lv_root | awk '{print $3}' | cut -d '"' -f2` nowatchdog module_blacklist=iTCO_wdt" >> $file_boot_loader_entries_arch_conf
	### if lv_swap does exists
	[ -d /dev/mapper/vg0-lv_swap ] && echo "options rd.luks.name=`blkid | grep crypto_LUKS | awk '{print $2}' | cut -d '"' -f2`=cryptlvm root=UUID=`blkid | grep lv_root | awk '{print $3}' | cut -d '"' -f2` rw resume=UUID=`blkid | grep lv_swap | awk '{print $3}' | cut -d '"' -f2` nowatchdog module_blacklist=iTCO_wdt" >> $file_boot_loader_entries_arch_conf

}


boot_loader_entry_lts_kernel() {

	file_boot_loader_entries_arch_lts_conf="/boot/loader/entries/arch-lts.conf"

	echo 'title arch-lts' > $file_boot_loader_entries_arch_lts_conf
	echo 'linux /vmlinuz-linux-lts' >> $file_boot_loader_entries_arch_lts_conf
	#[TODO] intel / amd check here
	echo 'initrd /intel-ucode.img' >> $file_boot_loader_entries_arch_lts_conf
	echo 'initrd /initramfs-linux-lts.img' >> $file_boot_loader_entries_arch_lts_conf
	### if lv_swap does not exist
	[ ! -d /dev/mapper/vg0-lv_swap ] && echo "options rd.luks.name=`blkid | grep crypto_LUKS | awk '{print $2}' | cut -d '"' -f2`=cryptlvm root=UUID=`blkid | grep lv_root | awk '{print $3}' | cut -d '"' -f2` nowatchdog module_blacklist=iTCO_wdt" >> $file_boot_loader_entries_arch_lts_conf
	### if lv_swap does exist
	[ -d /dev/mapper/vg0-lv_swap ] && echo "options rd.luks.name=`blkid | grep crypto_LUKS | awk '{print $2}' | cut -d '"' -f2`=cryptlvm root=UUID=`blkid | grep lv_root | awk '{print $3}' | cut -d '"' -f2` rw resume=UUID=`blkid | grep lv_swap | awk '{print $3}' | cut -d '"' -f2` nowatchdog module_blacklist=iTCO_wdt" >> $file_boot_loader_entries_arch_lts_conf

}


make_initramfs() {

	## for linux preset
	mkinitcpio -p linux

	## for linux-lts preset
	mkinitcpio -p linux-lts

}


cryto_remainings() {

	## ## sbupdate
	sbupdate

	## ## ##TODO probably an error here <<<<<<<<<<<<<<<<<<<<<<
	efibootmgr -c -d /dev/sdb -p 1 -L "Arch Linux" -l "EFI\Arch\linux-hardened-signed.efi"

}


cleanup_and_finish() {

	# move /hajime to $user home
	cp -r /hajime /home/$username
	sudo rm -rf /hajime

	touch /home/$username/hajime/2conf.done

	# human advice

	## exit arch-chroot environment
	## and return to archiso environment
	echo
	echo 'exit'

	## reboot advice
	echo 'umount -R /mnt'
	echo 'reboot'
	echo 'sh hajime/3post.sh'
	echo

}


set_time
set_locale
set_vconsole
set_hostname
create_hostname_file
#enable_systemd_resolved
root_password
user_name
user_add
user_groups
user_password
wheel_privilege_escalation
install_helpers
mirrorlist_configuration
#micro_code
install_core_applications
install_boot_files
configure_boot_loader
create_initramfs
#create_initramfs_crypto
#more_crypto
boot_loader_entry_ble_kernel
boot_loader_entry_lts_kernel
make_initramfs
#crypto_remainings
cleanup_and_finish
