#!/bin/bash
#
##
###  _            _ _                                  _
### | |__   __ _ (_|_)_ __ ___   ___   _ __   ___  ___| |_
### | '_ \ / _` || | | '_ ` _ \ / _ \ | '_ \ / _ \/ __| __|
### | | | | (_| || | | | | | | |  __/ | |_) | (_) \__ \ |_
### |_| |_|\__,_|/ |_|_| |_| |_|\___| | .__/ \___/|___/\__|3
###            |__/                   |_|
###  _ _|_ _ ._    _  _
### (_\/|_(_)|_)\/(_|(/_
###   /      |  /  _|
###
### hajime_post
### cytopyge arch linux installation 'post'
### third part of a series
###
### 2019 - 2022  |  cytopyge
###
##
#


# user customizable variables
offline=1
repo_dir="/home/$(id -un)/repo"
file_etc_pacman_conf='/etc/pacman.conf'

post_core_additions='lsof pacman-contrib mlocate neofetch wl-clipboard nvim archlinux-keyring'
bloat_ware="" # there seems to be no more bloatware since kernel v536 (nano was removed)
mirror_country='Sweden'
mirror_amount='5'


# functions


reply()
{
	# first silently entered character goes directly to $reply
	stty_0=$(stty -g)
	stty raw -echo
	reply=$(head -c 1)
	stty $stty_0
}


reply_single()
{
	# first entered character goes directly to $reply
	stty_0=$(stty -g)
	stty raw #-echo
	reply=$(head -c 1)
	stty $stty_0
}


dhcp_connect()
{
	sh hajime/0init.sh
}


set_read_write()
{
	# set /usr and /boot read-write
	sudo mount -o remount,rw  /usr
	sudo mount -o remount,rw  /boot
}


own_home()
{
	sudo chown -R $(id -un):$(id -gn) /home/$(id -un)
}


modify_pacman_conf()
{
	case $offline in

		1)
			## set offline repo
			sudo sed -i "/^\[offline\]/{n;s/.*/Server = file:\/\/\/home\/$(id -un)\/repo/}" $file_etc_pacman_conf
			#sudo sed -i "s|\/repo|$HOME\/repo|" $file_etc_pacman_conf
			;;

		*)
			## activate color
			sudo sed -i 's/#Color/Color/' $file_etc_pacman_conf

			## activate verbose package lists
			sudo sed -i 's/#VerbosePkgLists/VerbosePkgLists/' $file_etc_pacman_conf

			## activate parallel downloads
			sudo sed -i 's/#Parallel/Parallel/' pacman.conf
			#sudo awk '/VerbosePkgLists/ { print; print "ParallelDownloads = 5"; next }1' \
			#	$file_etc_pacman_conf > $file_etc_pacman_conf

			## activate multilib repository
			sudo sed -i 's/\#\[multilib\]/\[multilib\]\nInclude \= \/etc\/pacman.d\/mirrorlist/' $file_etc_pacman_conf
			;;

	esac
}


pacman_init()
{
	sudo pacman-key --init
	sudo pacman-key --populate archlinux
}


mount_repo()
{
	repo_lbl='REPO'
	repo_dev=$(lsblk -o label,path | grep "$repo_lbl" | awk '{print $2}')
	#local mountpoint=$(mount | grep $repo_dir)

	[[ -d $repo_dir ]] || mkdir -p "$repo_dir"

	sudo mount "$repo_dev" "$repo_dir"
	#[[ -n $mountpoint ]] || sudo mount "$repo_dev" "$repo_dir"
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


get_offline_repo()
{
	case $offline in
		1)
			mount_repo
			;;
	esac
}


create_directories() {
	# create mountpoint docking bays

	mkdir -p $HOME/dock/1
	mkdir -p $HOME/dock/2
	mkdir -p $HOME/dock/3
	mkdir -p $HOME/dock/4
	mkdir -p $HOME/dock/android
	mkdir -p $HOME/dock/transfer
	mkdir -p $HOME/dock/vlt
	#sudo mkdir -p $HOME/dock/1
	#sudo mkdir -p $HOME/dock/2
	#sudo mkdir -p $HOME/dock/3
	#sudo mkdir -p $HOME/dock/4
	#sudo mkdir -p $HOME/dock/android
	#sudo mkdir -p $HOME/dock/transfer
	#sudo mkdir -p $HOME/dock/vlt


	# create xdg directories

	mkdir -p $HOME/.local/share/archive
	mkdir -p $HOME/.local/share/backup
	mkdir -p $HOME/.local/share/data
	mkdir -p $HOME/.local/share/download
	mkdir -p $HOME/.local/share/keys
	mkdir -p $HOME/.local/share/media
	mkdir -p $HOME/.local/share/todo
	mkdir -p $HOME/.cache/temp
	mkdir -p $HOME/.cache/test
	mkdir -p $HOME/.config
	mkdir -p $HOME/.logs
	mkdir -p $HOME/.dot
}


base_mutations()
{
	## own home
	#sudo chown -R $USER:wheel $HOME

	## add post core addditions
	for package in $post_core_additions;
	do

		sudo pacman -S --needed --noconfirm $package

	done

	## remove base system bloat
	#pacman -Rns --noconfirm $bloat_ware


	## aur helper
	if [[ $offline -ne 1 ]]; then

		trizen()
		{
			mkdir -p $HOME/tmp/trizen
			git clone -q https://aur.archlinux.org/trizen.git $HOME/tmp/trizen
			cd $HOME/tmp/trizen
			makepkg -si
			cd
			#rm -rf $HOME/tmp
			trizen --version
		}

		trizen


		: '
		yay()
		{
			mkdir -p ~/tmp/yay
			git clone -q https://aur.archlinux.org/yay.git ~/tmp/yay
			cd ~/tmp/yay
			makepkg -si
			cd
			rm -rf ~/tmp
		}
		#yay
		# '

	fi
}


set_read_only()
{
	# set /usr and /boot read-only
	sudo mount -o remount,ro  /usr
	sudo mount -o remount,ro  /boot
}


wrap_up()
{
	# human info
	clear
	echo
	printf "congratulations, with your Arch Linux OS!\n"
	echo
	echo
	printf "your terminal is now ready to run independently\n"
	printf "proceed with your own personal configuration,\n"
	printf "or use an alternative desktop environment.\n"
	echo
	echo
	printf "continue with this installation series"
	printf "by running 4apps.sh (recommended):\n"
	echo
	printf "sh hajime/4apps.sh\n"
	echo
	echo
	printf "press any key to continue... "
	reply_single
	clear
	echo
	neofetch --gtk3 off
	sudo touch hajime/3post.done
}


main()
{
	dhcp_connect
	set_read_write
	own_home
	modify_pacman_conf
	pacman_init
	mount_repo
	create_directories
	base_mutations
	set_read_only
	wrap_up
}

main
