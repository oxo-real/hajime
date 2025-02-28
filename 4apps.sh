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


args="$@"
getargs ()
{
    ## online installation
    [[ "$1" =~ online$ ]] && online=1
}


offline_installation ()
{
    code_lbl=CODE
    code_dir="/home/$(id -un)/dock/3"
    repo_lbl=REPO
    repo_dir="/home/$(id -un)/dock/2"
    repo_re="\/home\/$(id -un)\/dock\/2"
    file_etc_pacman_conf='/etc/pacman.conf'
}


mount_repo ()
{
    repo_dev=$(lsblk -o label,path | grep "$repo_lbl" | awk '{print $2}')

    [[ -d $repo_dir ]] || mkdir -p "$repo_dir"

    mountpoint -q $repo_dir
    [[ $? -eq 0 ]] || sudo mount "$repo_dev" "$repo_dir"
}


get_offline_repo ()
{
    [[ $online -ne 1 ]] && mount_repo

    if [[ -z "$repo_dev" ]]; then

	printf 'ERROR device REPO not found\n'
	exit 30

    fi
}


mount_code ()
{
    code_dev=$(lsblk -o label,path | grep "$code_lbl" | awk '{print $2}')

    [[ -d $code_dir ]] || mkdir -p "$code_dir"

    mountpoint -q $code_dir
    [[ $? -eq 0 ]] || sudo mount "$code_dev" "$code_dir"
}


get_offline_code ()
{
    [[ $online -ne 1 ]] && mount_code

    if [[ -z "$code_dev" ]]; then

	printf 'ERROR device CODE not found\n'
	exit 40

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
    ## loop through core app packages
    ## instead of one whole list entry in yay
    ## this prevents that on error only one package is skipped
    #local packages=$(echo "${core_applications[*]}")
    #sudo pacman -S --noconfirm --needed $packages
    # for pkg_pca in "${post_core_applications[@]}"; do

    sudo pacman -S --needed --noconfirm "${apps_pkgs[@]}"

    # done
}


loose_ends ()
{
    #[TODO]remove candidate
    ## tmux_plugin_manager
    #tmux_plugin_dir="$HOME/.config/tmux/plugins"
    #git clone https://github.com/tmux-plugins/tpm $tmux_plugin_dir/tpm

    #[TODO]remove candidate
    ## create w3mimgdisplay symlink
    ## w3mimgdisplay is not in /usr/bin by default as of 20210114
    ## alternative is to add /usr/lib/w3m to $PATH
    #sudo ln -s /usr/lib/w3m/w3mimgdisplay /usr/bin/w3mimgdisplay

    ## recommend human to execute dotfiles install script
    echo 'sh hajime/5dtcf.sh'

    ## finishing
    sudo touch $HOME/hajime/4apps.done
}


autostart_next ()
{
    ## triggered with configuration file
    [[ -n $after_4apps ]] && sh $HOME/hajime/5dtcf.sh
}


main ()
{
    sourcing
    getargs $args
    offline_installation

    set_boot_rw
    set_usr_rw
    get_offline_repo
    get_offline_code

    install_apps_packages

    loose_ends
    set_boot_ro
    set_usr_ro

    autostart_next
}

main
