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
fourth part of linux installation
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
  sh hajime/4apps.sh [--online]

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

## hardcoded variables
# user customizable variables
file_hi_config="$HOME/hajime/install-config.sh"
file_hi_packages="$HOME/hajime/install-packages.sh"

#--------------------------------

sourcing ()
{
    ## configuration file
    [[ -f $file_hi_config ]] && source $file_hi_config

    ## sourcing apps_pkgs
    [[ -f $file_hi_packages ]] && source $file_hi_packages
}


debugging ()
{
    ## debug switch via configuration file
    ## -z debugging prevents infinite loop
    if [[ "$exec_mode" =~ debug* && -z "$debugging" ]]; then

	debugging=on
	debug_log="${hajime_src}/${script_name}-debug.log"

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


args="$@"
getargs ()
{
    ## online installation
    [[ "$1" =~ online$ ]] && online=1
}


installation_mode ()
{
    ## online or offline mode
    if [[ $online -ne 1 ]]; then

	code_lbl=CODE
	code_dir="/home/$(id -un)/dock/3"
	repo_lbl=REPO
	repo_dir="/home/$(id -un)/dock/2"
	repo_re="\/home\/$(id -un)\/dock\/2"
	file_etc_pacman_conf=/etc/pacman.conf

    elif [[ "$online" -eq 1 ]]; then

	:

    fi
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


install_apps_packages ()
{
    ## for to prevent pacman error exit
    for pkg in "${apps_pkgs[@]}"; do

	printf 'installing %s ' "$pkg"

	if ! pacman -S --needed --noconfirm "$pkg"; then

	    printf 'error - skipping\n'

	else

	    printf 'succes\n'

	fi

    done
    #sudo pacman -S --needed --noconfirm "${apps_pkgs[@]}"
}


install_aur_packages ()
{
    ## using yay
    for pkg in "${aur_pkgs[@]}"; do

	printf 'installing %s ' "$pkg"

	if ! yay -S --needed --noconfirm "$pkg"; then

	    printf 'error - skipping\n'

	else

	    printf 'succes\n'

	fi

    done

}


loose_ends ()
{
    ## recommend human to execute dotfiles install script
    echo 'sh hajime/5dtcf.sh'

    ## finishing
    sudo touch $HOME/hajime/4apps.done
}


autostart_next ()
{
    ## switch autostart via configuration file
    [[ -n $after_4apps ]] && sh $HOME/hajime/5dtcf.sh
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

    install_apps_packages
    install_aur_packages

    set_boot_ro
    set_usr_ro

    loose_ends

    autostart_next
}

main
