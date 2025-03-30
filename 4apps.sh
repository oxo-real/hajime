#! /usr/bin/env sh

###  _            _ _
### | |__   __ _ (_|_)_ __ ___   ___    __ _ _ __  _ __  ___
### | '_ \ / _` || | | '_ ` _ \ / _ \  / _` | '_ \| '_ \/ __|
### | | | | (_| || | | | | | | |  __/ | (_| | |_) | |_) \__ \
### |_| |_|\__,_|/ |_|_| |_| |_|\___|  \__,_| .__/| .__/|___/4
###            |__/                         |_|   |_|
###
###  # # # # # #
###       #
###  # # # # # #
###

: '
hajime_4apps
fourth linux installation module
copyright (c) 2019 - 2025  |  oxo

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
  fourth part of a series
  arch linux installation: apps

# dependencies
  archlinux installation
  archiso, REPO, 0init.sh, 1base.sh, 2conf.sh, 3post.sh

# usage
  sh hajime/4apps.sh [--offline|online|hybrid] [--config $custom_conf_file]

# example
  n/a

# '


#set -o errexit
#set -o nounset
set -o pipefail

# initial definitions

## script
script_name=4apps.sh
developer=oxo
license=gplv3
initial_release=2019

## absolute filepaths
file_etc_pacman_conf=/etc/pacman.conf
hajime_src="$HOME/dock/3/code/hajime"
yay_cache="$HOME/.cache/yay"
yay_src="$HOME/dock/2/yay"

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
    hajime_exec="$HOME/hajime"

    ## configuration file
    ### define
    #TODO
    file_setup_config_path="$hajime_exec"/temp/active.conf
    file_setup_config=$(head -n 1 "$file_setup_config_path")
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
    file_error_log="$hajime_exec"/logs/"$script_name"-error.log

    file_pacman_offline_conf="$hajime_exec"/setup/pacman/pm_offline.conf
    file_pacman_online_conf="$hajime_exec"/setup/pacman/pm_online.conf
    file_pacman_hybrid_conf="$hajime_exec"/setup/pacman/pm_hybrid.conf

    if [[ -z "$cfv" ]]; then
	## no config file value given

	## set default values based on existing path in file from 3post
	file_setup_config_path="$hajime_exec"/temp/active.conf
	file_setup_config_3post=$(cat $file_setup_config_path)
	## /hajime/setup/machine is always a part of path in file
	machine_file_name="${file_setup_config_3post#*/hajime/setup/machine/}"
	file_setup_config="$hajime_exec"/setup/machine/"$machine_file_name"

	printf '%s\n' "$file_setup_config" > "$file_setup_config_path"

    fi
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
	sh "$hajime_exec"/0init.sh --pit 4

    fi
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


set_boot_rw ()
{
    ## set /boot writeable
    sudo mount -o remount,rw  /boot
}


set_boot_ro ()
{
    # reset /boot read-only
    sudo mount -o remount,ro  /boot
}


set_usr_rw ()
{
    ## set /usr writeable
    sudo mount -o remount,rw  /usr
}


set_usr_ro ()
{
    # reset /usr read-only
    sudo mount -o remount,ro  /usr
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

    sudo pacman -Syyu --config "$pm_alt_conf" --noconfirm
}


install_yay ()
{
    if ! pacman -Qs --config "$pm_alt_conf" yay; then
	## yay is not already installed

	## ## from https://github.com/Jguer/yay/releases
	## ## add the latest x86_64.tar.gz
	## ## i.e. https://github.com/Jguer/yay/releases/download/v12.4.2/yay_12.4.2_x86_64.tar.gz
	## ## to yay_src/yay-bin (which is inside the REPO on dock/2)

	## create location for foreign package repository
	[[ -d "$yay_cache" ]] || mkdir -p "$yay_cache"

	## goto foreign package repository
	cd "$yay_cache"

	if [[ "$online" -eq 0 ]]; then
	    ## offline mode

	    ## copy offline yay-bin
	    # cp -r "$yay_src"/yay-bin "$yay_cache"
	    ## .git/objects contains root ownership
	    rsync -aAXv --exclude .git "$yay_src"/yay-bin "$yay_cache"

	elif [[ "$online" -ne 0 ]]; then
	    ## online or hybrid mode

	    ## clone online yay-bin upstream source
	    git clone https://aur.archlinux.org/yay-bin.git

	fi

	## goto yay_cache yay-bin
	# cd yay-bin

	## ## in PKGBUILD redirect source_x86_64 to the added x86_64.tar.gz file:
	## ## source_x86_64=("$HOME/.cache/yay/yay-bin/${pkgname/-bin/}_${pkgver}_x86_64.tar.gz")

	## makepkg, sync dependencies and install package
	makepkg --dir "$yay_cache"/yay-bin --syncdeps --install --needed --noconfirm

	## return home
	cd

    else

	printf 'yay already installed\n'

    fi
}


install_apps_pkgs ()
{
    ## for to prevent pacman exit on error
    ## apps_pkgs sourced via setup/package.list
    #TODO
    #yay -S --config "$pm_alt_conf" --needed --noconfirm "${apps_pkgs[@]}"
    for pkg in "${apps_pkgs[@]}"; do

	if ! yay -S --config "$pm_alt_conf" --needed --noconfirm "$pkg"; then

	    printf 'ERROR yay -S --config %s --needed --noconfirm %s\n' "$pm_alt_conf" "$pkg" | tee -a $file_error_log

	    install_aur_pkg

	fi

    done
}


loose_ends ()
{
    ## recommend human to execute dotfiles configuration script
    echo 'sh hajime/5dtcf.sh'

    ## finishing
    sudo touch $HOME/hajime/4apps.done
}


autostart_next ()
{
    ## switch autostart via configuration file
    [[ -n $after_4apps ]] && sh "$hajime_exec"/5dtcf.sh
}


debugging ()
{
    ## debug switch via configuration file
    ## -z debugging prevents infinite loop
    if [[ "$exec_mode" =~ debug* && -z "$debugging" ]]; then

	debugging=on
	debug_log="${hajime_exec}/${script_name}-debug.log"

	## debug header
	printf '>>> %s_%X %s/%s-debug.log\n' "$(date +%Y%m%d_%H%M%S)" "$(date +'%s')" "$hajime_src" "$script_name"
	echo

	case "$exec_mode" in

	    debug )
		## start script in debug mode
 		sh "$hajime_src"/"$script_name" 2>&1 | tee -a "$debug_log"
		;;

	    debug_verbose )
		## start script in verbose debug mode
 		sh -x "$hajime_src"/"$script_name" 2>&1 | tee -a "$debug_log"
		;;

	esac

	unset debugging
	exit 0

    fi
}


main ()
{
    sourcing
    debugging
    getargs $args
    installation_mode

    set_boot_rw
    set_usr_rw

    get_offline_repo
    get_offline_code

    configure_pacman
    install_yay
    install_apps_pkgs

    set_boot_ro
    set_usr_ro

    loose_ends

    autostart_next
}

main
