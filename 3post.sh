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
third linux installation module
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

# dependencies
  0init.sh, 1base.sh, 2conf.sh

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
file_etc_motd=/etc/motd
file_etc_pacman_conf=/etc/pacman.conf

## CODE and REPO mountpoints
code_lbl=CODE
code_dir="$HOME"/dock/3
repo_lbl=REPO
repo_dir="$HOME"/dock/2
repo_re="${HOME}"\/dock\/2


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
    hajime_exec="$HOME"/hajime

    relative_file_paths

    ## configuration file
    ### define
    file_setup_config=$(head -n 1 "$file_setup_config_path")
    ### source
    [[ -f "$file_setup_config" ]] && source "$file_setup_config"

    ## package list
    ### define
    file_setup_package_list="$hajime_exec"/setup/package.list
    ### source
    [[ -f "$file_setup_package_list" ]] && source "$file_setup_package_list"

    ## user owns home, not root
    own_home

    ## config file is sourced; reevaluate explicit arguments
    explicit_arguments
}


relative_file_paths ()
{
    ## independent (i.e. no if) relative file paths
    file_pacman_offline_conf="$hajime_exec"/setup/pacman/pm_offline.conf
    file_pacman_online_conf="$hajime_exec"/setup/pacman/pm_online.conf
    file_pacman_hybrid_conf="$hajime_exec"/setup/pacman/pm_hybrid.conf

    if [[ -z "$cfv" ]]; then
	## no config file value given

	## set default values based on existing path in file from 2conf
	file_setup_config_path="$hajime_exec"/temp/active.conf
	file_setup_config_2conf=$(cat $file_setup_config_path)
	## /hajime/setup/machine is always a part of path in file
	machine_file_name="${file_setup_config_2conf#*/hajime/setup/machine/}"
	file_setup_config="$hajime_exec"/setup/machine/"$machine_file_name"

	printf '%s\n' "$file_setup_config" > "$file_setup_config_path"

    fi
}


explicit_arguments ()
{
    ## explicit arguments override default and configuration settings
    ## regarding network installation mode

    if [[ "$offline_arg" -eq 1 ]]; then
	## offline mode (forced)

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

	## early sourcing hajime_exec
	hajime_exec="$HOME"/hajime

	file_setup_config_path="$hajime_exec"/temp/active.conf
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


define_text_appearance()
{
    ## text color
    fg_magenta='\033[0;35m' # magenta
    fg_green='\033[0;32m'   # green
    fg_red='\033[0;31m'     # red

    ## text style
    st_def='\033[0m'        # default
    st_ul=`tput smul`       # underline
    st_bold=`tput bold`     # bold
}


installation_mode ()
{
    if [[ "$online" -ne 0 ]]; then
	## online or hybrid mode

	## dhcp connect
	export hajime_exec
	sh "$hajime_exec"/0init.sh --pit 3

    fi
}


create_home ()
{
    ## create mountpoint docking bays
    mkdir -p "$HOME"/dock/{1,2,3,4,mobile,transfer,vlt}

    ## create xdg directories
    mkdir -p "$HOME"/.cache/{temp,test}
    mkdir -p "$HOME"/.config
    mkdir -p "$HOME"/.local/share
    mkdir -p "$HOME"/.logs
}


own_home ()
{
    sudo chown -R $(id -un):$(id -gn) /home/$(id -un)
}


mount_repo ()
{
    repo_dev=$(lsblk -o label,path | grep "$repo_lbl" | awk '{print $2}')

    [[ -d $repo_dir ]] || mkdir -p "$repo_dir"

    mountpoint -q "$repo_dir"
    [[ $? -ne 0 ]] && sudo mount -o ro "$repo_dev" "$repo_dir"
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
    [[ $? -ne 0 ]] && sudo mount -o ro "$code_dev" "$code_dir"
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

    ## update offline repo name in pm_alt_conf
    ## previous repo path (2conf repo_dir)
    pm_2conf_path=/root/tmp/repo
    ## replace with current repo path
    sed -i "s#${pm_2conf_path}#${repo_dir}#" "$pm_alt_conf"
}


pacman_init ()
{
    sudo pacman-key --config "$pm_alt_conf" --init
    sudo pacman-key --config "$pm_alt_conf" --populate archlinux

    # sudo pacman -Syyu --config "$pm_alt_conf"
    sudo pacman -Syyu --needed --noconfirm --dbpath "$repo_dir"/ofcl/db --cachedir "repo_dir"/ofcl/pkgs
}


install_post_pkgs ()
{
    ## add post core addditions
    # sudo pacman -S --config "$pm_alt_conf" --needed --noconfirm "${post_pkgs[@]}"
    sudo pacman -S --needed --noconfirm --dbpath "$repo_dir"/ofcl/db --cachedir "repo_dir"/ofcl/pkgs "${post_pkgs[@]}"
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
    [[ -n $after_3post ]] && sh "$hajime_exec"/4apps.sh
}


main ()
{
    getargs $args
    sourcing
    define_text_appearance
    installation_mode
    motd_remove
    create_home
    get_offline_repo
    get_offline_code
    set_read_write
    configure_pacman
    pacman_init
    install_post_pkgs
    set_read_only
    wrap_up
    autostart_next
}

main
