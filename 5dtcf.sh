#! /usr/bin/env sh

###  _            _ _                      _ _        __
### | |__   __ _ (_|_)_ __ ___   ___    __| | |_ ___ / _|
### | '_ \ / _` || | | '_ ` _ \ / _ \  / _` | __/ __| |_
### | | | | (_| || | | | | | | |  __/ | (_| | || (__|  _|
### |_| |_|\__,_|/ |_|_| |_| |_|\___|  \__,_|\__\___|_| 5
###            |__/
###
###  # # # # # #
###       #
###  # # # # # #
###

: '
hajime_5dtcf
fifth linux installation module
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
  grande finale: fifth and last module of a series
  arch linux installation: dotfile configuration

# dependencies
  arch installation
  archiso, REPO, 0init.sh, 1base.sh, 2conf.sh, 3post.sh, 4apps.sh

# usage
  sh hajime/5dtcf.sh [--offline|online|hybrid] [--config $custom_conf_file]

# example
  n/a

# '


#set -o errexit
#set -o nounset
set -o pipefail

# initial definitions

## script
script_name=5dtcf.sh
developer=oxo
license=gplv3
initial_release=2019

## hardcoded variables
# user customizable variables

## main xdg locations
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_LOGS_HOME="$HOME/.logs"
export XDG_CONFIG_DIRS=/etc/xdg

## main git locations
git_local="$XDG_DATA_HOME/c/git"
git_remote=https://codeberg.org/oxo

## CODE and REPO mountpoints
code_lbl=CODE
code_dir="$HOME"/dock/3
repo_lbl=REPO
repo_dir="$HOME"/dock/2
repo_re="${HOME}"\/dock\/2

file_etc_pacman_conf=/etc/pacman.conf

## absolute file paths
hajime_src="$code_dir"/code/hajime
etc_doas_conf=/etc/doas.conf


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
		## specific arguments overrule defaults or configuration file setting

		## offline installation
		[[ "$1" =~ offline$ ]] && offline_arg=1 && online=0
		shift
		;;

	    --online )
		## specific arguments overrule defaults or configuration file setting

		## online installation
		[[ "$1" =~ online$ ]] && online_arg=1 && online="$online_arg"
		shift
		;;

	    --hybrid )
		## specific arguments overrule defaults or configuration file setting

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
    file_setup_config_path="$hajime_exec"/temp/active.conf
    file_setup_config=$(head -n 1 "$file_setup_config_path")
    ### source
    [[ -f "$file_setup_config" ]] && source "$file_setup_config"

    ## package list
    ### define
    file_setup_package_list="$hajime_exec"/setup/package-list.sh
    ### source
    [[ -f "$file_setup_package_list" ]] && source "$file_setup_package_list"

    relative_file_paths

    ## config file is sourced; reevaluate specific arguments
    specific_arguments
}


relative_file_paths ()
{
    ## independent (i.e. no if) relative file paths
    file_pacman_offline_conf="$hajime_exec"/setup/pacman/pm_offline.conf
    file_pacman_online_conf="$hajime_exec"/setup/pacman/pm_online.conf
    file_pacman_hybrid_conf="$hajime_exec"/setup/pacman/pm_hybrid.conf

    if [[ -z "$cfv" ]]; then
	## no config file value given

	## set default values based on existing path in file from 4apps
	file_setup_config_path="$hajime_exec"/temp/active.conf
	file_setup_config_4apps=$(cat $file_setup_config_path)
	## /hajime/setup/machine is always a part of path in file
	machine_file_name="${file_setup_config_4apps#*/hajime/setup/machine/}"
	file_setup_config="$hajime_exec"/setup/machine/"$machine_file_name"

	printf '%s\n' "$file_setup_config" > "$file_setup_config_path"

    fi

    ## doas configuration file
    file_setup_doas_conf="$hajime_exec"/setup/doas/etc_doas.conf
}


specific_arguments ()
{
    ## specific arguments override default and configuration settings
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
	sh "$hajime_exec"/0init.sh --pit 5

    fi
}


debugging ()
{
    ## debug switch via configuration file
    echo
    echo
    [[ -n "$debug_log" ]] \
	&& printf '-------------------- %s_%X %s\n' "$(date +%Y%m%d_%H%M%S)" "$(date +'%s')" "$script_name"
    echo
    echo
}


mount_repo ()
{
    repo_dev=$(lsblk -o label,path | grep "$repo_lbl" | awk '{print $2}')

    [[ -d $repo_dir ]] || mkdir -p "$repo_dir"

    mountpoint -q $repo_dir
    [[ $? -eq 0 ]] || sudo mount -o ro "$repo_dev" "$repo_dir"
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

    mountpoint -q $code_dir
    [[ $? -eq 0 ]] || sudo mount -o ro "$code_dev" "$code_dir"
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


git_clone_remote_local ()
{
    local remote_repo="$git_remote/$git_repo"
    local local_dir="$git_local/$local_repo"
    #[ -d $local_dir ] || mkdir -p $local_dir

    git clone $remote_repo $local_dir
}


git_clone_dotf ()
{
    git_repo='dotf'
    local_repo='dotf'
    git_clone_remote_local
}


git_clone_code ()
{
    ### hajime
    git_repo='hajime'
    local_repo="code/$git_repo"
    git_clone_remote_local

    ### isolatest
    git_repo='isolatest'
    local_repo="code/$git_repo"
    git_clone_remote_local

    ### network
    git_repo='network'
    local_repo="code/$git_repo"
    git_clone_remote_local

    ### source
    git_repo='source'
    local_repo="code/$git_repo"
    git_clone_remote_local

    ### tool
    git_repo='tool'
    local_repo="code/$git_repo"
    git_clone_remote_local
}


git_clone_note ()
{
    git_repo='note'
    local_repo="$git_repo"
    git_clone_remote_local
}


get_git_repo ()
{
    if [[ "$online" -eq 0 ]]; then
	## offline mode

	## define destinations
	home_dir_dst="$HOME"
	git_dir_dst="$XDG_DATA_HOME/c/git"

	[[ -d $home_dir_dst/.config ]] || mkdir -p  $home_dir_dst/.config
	[[ -d $git_dir_dst/dotf ]] || mkdir -p	    $git_dir_dst/dotf
	[[ -d $git_dir_dst/code ]] || mkdir -p	    $git_dir_dst/code
	[[ -d $git_dir_dst/note ]] || mkdir -p	    $git_dir_dst/note

	printf "copying configuration files\n"
	## TODO error for .git files
	src="$code_dir/.config"
	dst="$home_dir_dst"
	rsync -aAXv $src $dst
	#cp -pr $code_dir/.config    $home_dir_dst
	printf "done\n"

	printf "copying code repository\n"
	src="$code_dir/dotf"
	dst="$git_dir_dst"
	rsync -aAXv $src $dst
	#cp -pr $code_dir/dotf	    $git_dir_dst
	printf "done\n"

	printf "copying code repository\n"
	src="$code_dir/code"
	dst="$git_dir_dst"
	rsync -aAXv $src $dst
	#cp -pr $code_dir/code	    $git_dir_dst
	printf "done\n"

	printf "copying note repository\n"
	src="$code_dir/note"
	dst="$git_dir_dst"
	rsync -aAXv $src $dst
	#cp -pr $code_dir/note	    $git_dir_dst
	printf "done\n"

    elif [[ $online -ne 0 ]]; then
	## online or hybrid mode

	git_clone_dotf
	git_clone_code
	git_clone_note

    fi
}


dotfbu_restore ()
{
    # restore .config from local git dotf
    sh $XDG_DATA_HOME/c/git/code/tool/dotfbu restore $XDG_DATA_HOME/c/git/dotf $XDG_CONFIG_HOME
}


user_agent ()
{
    ## create an initial user-agent to prevent error from zshenv
    ## [The Latest and Most Common User Agents List (Updated Weekly)](https://www.useragents.me/)
    ## 20250407
    ua='Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.10 Safari/605.1.1'
    lnua="$XDG_LOGS_HOME"/network/user_agent
    lnuac="$lnua"/current
    [[ -d "$lnua" ]] || mkdir -p "$lnua"
    printf '%s\n' "$ua" > "$lnuac"
}


rewrite_symlinks ()
{
    # rewrite symlinks in shln to current users home

    ## create symlinks in $HOME
    ### to pass_vault mountpoint (vlt_pass)
    ln --symbolic --force $HOME/dock/vlt/pass $HOME/.password-store

    ### to archive, backup, current and device
    ln --symbolic --force $HOME/.local/share/a $HOME/a
    ln --symbolic --force $HOME/.local/share/b $HOME/b
    ln --symbolic --force $HOME/.local/share/c $HOME/c
    ln --symbolic --force $HOME/.local/share/d $HOME/d

    ## change $USER for all broken symlinks in $HOME (recursive) to $HOME/*
    echo
    printf 'updating symlinks in $HOME\n'
    sh $XDG_DATA_HOME/c/git/code/tool/chln $XDG_CONFIG_HOME
    sh $XDG_DATA_HOME/c/git/code/tool/chln $HOME/c

    ## wireguard interface symlinks
    cnvwpi="$XDG_CONFIG_HOME"/network/vpn/wg/proton/interface
    etc_wg=/etc/wireguard
    sudo ln -s "$cnvwpi"/wg*.conf "$etc_wg"

    ## z-shell config root like user
    rc=/root/.config
    sudo mkdir -p "$rc"
    sudo ln -s "$XDG_CONFIG_HOME"/.config/zsh "$rc"/zsh

    ## zsh default shell for root
    sudo chsh -s /usr/bin/zsh root
}


recalculate_sums ()
{
    lscgc="$XDG_DATA_HOME"/c/git/code

    while read sum; do

	sh "$lscgc"/tool/calc-sum --noconfirm $(dirname "$sum")

    done <<< $(find "$lscgc" -type f -name 'sha3-512sums')
}


set_doas ()
{
    # configure doas
    # sudo printf 'permit persist :wheel\n' > $etc_doas_conf
    # sudo chown -c root:root $etc_doas_conf
    # sudo chmod -c 0400 $etc_doas_conf
    sudo cp "$file_setup_doas_conf" "$etc_doas_conf"

    ## test for errors
    if ! sudo doas -C "$etc_doas_conf"; then

	printf 'ERROR doas config\n'

    fi
}


set_permissions ()
{
    # set right permissions for gnupg home
    sh $XDG_DATA_HOME/c/git/note/crypto/gpg/gnupg_set_permissions
}


z_shell_config ()
{
    ## re-login or reset shell for changes to take effect

    ## symlink in etc_zsh to zshenv
    sudo ln -s $XDG_CONFIG_HOME/zsh/etc_zsh_zshenv /etc/zsh/zshenv

    ## zsh default shell for current user
    #sudo chsh -s $(which zsh)

    ## zsh default shell for $USER (alt1)
    #sudo usermod -s $(which zsh) $USER

    ## zsh default shell for $USER, changing /etc/passwd directly (alt2)
    sudo awk -F ':' -v user="$USER" \
	 'BEGIN {OFS=":"} \
	 $1 == user { $NF="/usr/bin/zsh"; print } \
	 $1 != user { print }' \
	 /etc/passwd > $XDG_CACHE_HOME/temp/passwd \
	 && sudo mv $XDG_CACHE_HOME/temp/passwd /etc/passwd
    # awk field separator ':'; set variable 'user' to $USER
    # OFS output field separator ':'
    # if field1 (username) matches 'user', change $NF last field (shell) to '/bin/zsh' and print the line
    # if field1 does not match 'user', print the line as is
    # read from /etc/passwd and redirect output to a temporary file &&
    # move the temporary file back to overwrite the original /etc/passwd

    ## enable command history
    [[ -d "$XDG_LOGS_HOME/history" ]] || mkdir $XDG_LOGS_HOME/history
    touch $XDG_LOGS_HOME/history/history
}


set_sway_hardware ()
{
    # sh $XDG_CONFIG_HOME/sway/hw/select_current_machine
    unlink $XDG_DATA_HOME/sway/current
    ln --symbolic --force $XDG_CONFIG_HOME/sway/machine/"$sway_machine" $XDG_DATA_HOME/sway/current
}


base16 ()
{
    export BASE16_THEME=ir-black
    #export BASE16_THEME=synth-midnight-dark
}


qutebrowser ()
{
    ## qutebrowser download directory
    qb_dl_dir="$XDG_DATA_HOME/c/download"
    [ -d $qb_dl_dir ] || mkdir -p $qb_dl_dir
}


wallpaper ()
{
    ## prepare wallpaper file
    [ -d $XDG_DATA_HOME/a/media/images/wallpaper ] || \
	mkdir -p $XDG_DATA_HOME/a/media/images/wallpaper

    #cp $XDG_DATA_HOME/media/images/wallpaper/preferred-image.png $XDG_DATA_HOME/media/images/wallpaper/active
}


pacman_conf ()
{
    ## disabling offline repo
    sudo sed -i '/^\[offline\]/ s/./#&/' $file_etc_pacman_conf
    sudo sed -i '/^Server = file:\/\// s/./#&/' $file_etc_pacman_conf

    ## restore default online pacman.conf repositories
    sudo sed -i 's/^#X--//' $file_etc_pacman_conf

    ## check for network
    ping -D -i 1 -c 3 9.9.9.9 > /dev/null 2>&1

    if [[ $? -eq 0 ]]; then
	## network available

	## synchronize package databases
	sudo pacman -Syy

    fi
}


cursor_shapes ()
{
    ## from: note/linux/arch/icons/cursor
    ## reset oxo cursor setup
    pilot="$XDG_CONFIG_HOME"/icons/cursors/oxo/pilot
    copilot="$XDG_CONFIG_HOME"/icons/cursors/oxo/copilot
    usiac=/usr/share/icons/Adwaita/cursors

    sudo mount -o remount,rw /usr

    ## copy cursor shapes to usiac
    sudo cp "$pilot" "$usiac"
    sudo cp "$copilot" "$usiac"

    ## backup original cursor shapes
    [[ -f "$usiac"/text ]] && sudo cp "$usiac"/text "$usiac"/text_ORG
    [[ -f "$usiac"/xterm ]] && sudo cp "$usiac"/xterm "$usiac"/xterm_ORG
    [[ -f "$usiac"/default ]] && sudo cp "$usiac"/default "$usiac"/default_ORG
    [[ -f "$usiac"/left_ptr ]] && sudo cp "$usiac"/left_ptr "$usiac"/left_ptr_ORG
    [[ -f "$usiac"/hand2 ]] && sudo cp "$usiac"/hand2 "$usiac"/hand2_ORG

    ## symlink cursor shapes to (co)pilot
    ## CAUTION overwrites existing files
    sudo ln -s -f "$usiac"/pilot "$usiac"/text
    sudo ln -s -f "$usiac"/pilot "$usiac"/xterm
    sudo ln -s -f "$usiac"/copilot "$usiac"/default
    sudo ln -s -f "$usiac"/copilot "$usiac"/left_ptr
    sudo ln -s -f "$usiac"/copilot "$usiac"/hand2

    sudo mount -o remount,ro /usr
}


finishing_up ()
{
    # finishing

    ## administration
    sudo touch $HOME/hajime/5dtcf.done


    echo 'finished installation'
    read -p "abort reboot? [Y/n] " -n 1 -r reply

    if [[ "$reply" =~ ^[Nn]$ ]] ; then

	sudo reboot

    elif [[ -z "$reply" ]] ; then

	## auto reboot after timeout
	sudo reboot

    else

	exit

    fi
}


main ()
{
    debugging
    sourcing
    getargs $args
    get_offline_repo
    get_offline_code
    get_git_repo
    dotfbu_restore
    rewrite_symlinks
    recalculate_sums
    set_doas
    set_permissions
    z_shell_config
    set_sway_hardware
    base16
    user_agent
    qutebrowser
    #wallpaper
    pacman_conf
    cursor_shapes
    finishing_up
}

main
