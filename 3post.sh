#! /usr/bin/env sh

###  _            _ _                                  _
### | |__   __ _ (_|_)_ __ ___   ___   _ __   ___  ___| |_
### | '_ \ / _` || | | '_ ` _ \ / _ \ | '_ \ / _ \/ __| __|
### | | | | (_| || | | | | | | |  __/ | |_) | (_) \__ \ |_
### |_| |_|\__,_|/ |_|_| |_| |_|\___| | .__/ \___/|___/\__|3
###            |__/                   |_|
###
###  # # # # # #
###       #
###  # # # # # #
###

: '
hajime_3post
third part of linux installation
copyright (c) 2018 - 2025  |  oxo

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
  third part of a series
  arch linux installation: post
  branch archinst: after default archinstall

# dependencies
  archinstall, !REPO, 0init.sh, 1base.sh, 2conf.sh

# usage
  sh hajime/3post.sh [--offline|online|hybrid] [--config $custom_conf_file]

# example
  n/a

# '


#set -o errexit
#set -o nounset
set -o pipefail


# initial definitions

## script
script_name=3post.sh
developer=oxo
license=gplv3
initial_release=2018

## hardcoded variables
# user customizable variables

mirror_country=USA
mirror_amount=5

## absolute file paths
hajime_src=/root/tmp/code/hajime
file_etc_motd=/etc/motd
file_etc_pacman_conf=/etc/pacman.conf

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
    hajime_exec="$HOME/hajime"

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
    if [[ "$online" -ne 0 ]]; then
	## online or hybrid mode

	## dhcp connect
	export hajime_exec
	sh hajime/0init.sh --pit 3

    fi
}


configure_pacman ()
{
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

    ## update offline repo name in /etc/pacman.conf
    sed -i "s#0init_repo_here#${repo_dir}#" "pm_alt_conf"
}


pacman_init ()
{
    sudo pacman-key --config "$pm_alt_conf" --init
    sudo pacman-key --config "$pm_alt_conf" --populate archlinux
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


motd_remove ()
{
    sudo rm -rf $file_etc_motd
}


reply ()
{
    # first silently entered character goes directly to $reply
    stty_0=$(stty -g)
    stty raw -echo
    reply=$(head -c 1)
    stty $stty_0
}


reply_single ()
{
    # first entered character goes directly to $reply
    stty_0=$(stty -g)
    stty raw #-echo
    reply=$(head -c 1)
    stty $stty_0
}


set_read_write ()
{
    # set /usr and /boot read-write
    sudo mount -o remount,rw  /usr
    sudo mount -o remount,rw  /boot
}


own_home ()
{
    sudo chown -R $(id -un):$(id -gn) /home/$(id -un)
}


create_directories ()
{
    # create mountpoint docking bays

    mkdir -p $HOME/dock/1
    mkdir -p $HOME/dock/2
    mkdir -p $HOME/dock/3
    mkdir -p $HOME/dock/4
    mkdir -p $HOME/dock/android
    mkdir -p $HOME/dock/transfer
    mkdir -p $HOME/dock/vlt


    # create xdg directories

    mkdir -p $HOME/.cache/temp
    mkdir -p $HOME/.cache/test
    mkdir -p $HOME/.config
    mkdir -p $HOME/.local/share
    mkdir -p $HOME/.logs
}


base_mutations ()
{
    ## add post core addditions
    sudo pacman -S --needed --noconfirm "${post_pkgs[@]}"
}


set_read_only ()
{
    # set /usr and /boot read-only
    sudo mount -o remount,ro  /usr
    sudo mount -o remount,ro  /boot
}


wrap_up ()
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
    printf "continue with this installation series\n"
    printf "by running 4apps.sh (recommended):\n"
    echo
    printf "sh hajime/4apps.sh\n"
    echo
    echo
    printf "press any key to continue... "
    reply_single
    clear
    echo
    neofetch --ascii_distro arch_small --gtk3 off --gtk2 off --colors 3 3 3 7 3 4 --separator '     \t'
    sudo touch hajime/3post.done
}


autostart_next ()
{
    ## switch autostart via configuration file
    [[ -n $after_3post ]] && sh $HOME/hajime/4apps.sh
}


main ()
{
    sourcing
    getargs $args
    motd_remove
    get_offline_repo
    get_offline_code
    installation_mode
    configure_pacman
    pacman_init
    set_read_write
    own_home
    create_directories
    base_mutations
    set_read_only
    wrap_up
    autostart_next
}

main
