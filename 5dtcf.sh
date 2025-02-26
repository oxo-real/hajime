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
fifth part of linux installation
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
  grande finale: fifth and last part of a series
  arch linux installation: dotfile configuration

# dependencies
  arch installation
  archiso, REPO, 0init.sh, 1base.sh, 2conf.sh, 3post.sh, 4apps.sh

# usage
  sh hajime/5dtcf.sh

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

## offline installation
code_lbl=CODE
code_dir="/home/$(id -un)/dock/3"
repo_lbl=REPO
repo_dir="/home/$(id -un)/dock/2"
repo_re="\/home\/$(id -un)\/dock\/2"
file_etc_pacman_conf=/etc/pacman.conf

## doas configuration file
etc_doas_conf=/etc/doas.conf
misc_doas_conf="$HOME/hajime/misc/etc_doas.conf"

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
    #### git/hajime becomes the git repo;
    #### remove git repo from install directory
    rm -rf $HOME/hajime

    ### isolatest
    git_repo='isolatest'
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

    ### netconn
    git_repo='netconn'
    local_repo="code/$git_repo"
    git_clone_remote_local
}


git_clone_note ()
{
    git_repo='note'
    local_repo="$git_repo"
    git_clone_remote_local
}


git_clone_prvt ()
{
    git_repo='prvt'
    local_repo="$git_repo"
    git_clone_remote_local
}


get_git_repo ()
{
    if [[ $online -eq 1 ]]; then

	git_clone_dotf
	git_clone_code
	git_clone_note

    elif [[ $online -ne 1 ]]; then

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

    fi
}


dotfbu_restore ()
{
    if [[ $online -eq 1 ]]; then

	# restore .config from dotf
	sh $XDG_DATA_HOME/c/git/code/tool/dotfbu restore $XDG_DATA_HOME/c/git/dotf/ $XDG_CONFIG_HOME

    fi
}


rewrite_symlinks ()
{
    # rewrite symlinks in shln to current users home

    ## create symlinks
    ### to pass_vault mountpoint (vlt_pass)
    ln -s $HOME/dock/vlt/pass $HOME/.password-store

    ### to archive, backup, current and device
    ln -s $HOME/.local/share/a $HOME/a
    ln -s $HOME/.local/share/b $HOME/b
    ln -s $HOME/.local/share/c $HOME/c
    ln -s $HOME/.local/share/d $HOME/d

    ## change $USER symlinks
    ### change config_shln (default)
    sh $XDG_DATA_HOME/c/git/code/tool/chln
    ### change network_ua (non default)
    sh $XDG_DATA_HOME/c/git/code/tool/chln $XDG_CONFIG_HOME/network/ua
    ### change code_blocklist (non default)
    sh $XDG_DATA_HOME/c/git/code/tool/chln $XDG_DATA_HOME/c/git/code/blocklist
}


set_permissions ()
{
    # configure doas
    # sudo printf 'permit persist :wheel\n' > $etc_doas_conf
    # sudo chown -c root:root $etc_doas_conf
    # sudo chmod -c 0400 $etc_doas_conf
    sudo cp $misc_doas_conf $etc_doas_conf

    ## test for errors
    if ! sudo doas -C $etc_doas_conf; then

	printf 'ERROR doas config\n'

    fi

    # set right permissions for gnupg home
    sh $XDG_DATA_HOME/c/git/note/crypto/gpg/gnupg_set_permissions
}


z_shell_config ()
{
    ## reset or re-login for changes to take effect

    ## symlink in etc_zsh to zshenv
    sudo ln -s $XDG_CONFIG_HOME/zsh/etc_zsh_zshenv /etc/zsh/zshenv

    ## zsh default shell
    #sudo chsh -s $(which zsh)

    ## alt1: zsh default shell for $USER
    #sudo usermod -s $(which zsh) $USER

    ## alt2: zsh default shell by changing /etc/passwd directly
    sudo awk -F ':' -v user="$USER" \
	 'BEGIN {OFS=":"} \
	 $1 == user { $NF="/usr/bin/zsh"; print } \
	 $1 != user { print }' \
	 /etc/passwd > /tmp/passwd && sudo mv /tmp/passwd /etc/passwd
    # Run awk with ':' as the field separator and set the variable 'user' to the current username
    # Set the output field separator to ':'
    # If the first field (username) matches 'user', change the last field (shell) to '/bin/zsh' and print the line
    # If the first field does not match 'user', print the line as is
    # Read from /etc/passwd and redirect output to a temporary file &&
    # Move the temporary file back to overwrite the original /etc/passwd

    ## enable command history
    [[ -d "$XDG_LOGS_HOME/history" ]] || mkdir $XDG_LOGS_HOME/history
    touch $XDG_LOGS_HOME/history/history
}


set_sway_hardware ()
{
    sh $XDG_CONFIG_HOME/sway/hw/select_current_machine
}


base16 ()
{
    export BASE16_THEME=ir-black
    #export BASE16_THEME=synth-midnight-dark
}


qutebrowser ()
{
    # qutebrowser download directory
    qb_dl_dir="$XDG_DATA_HOME/c/download"
    [ -d $qb_dl_dir ] || mkdir -p $qb_dl_dir
}


wallpaper ()
{
    # prepare wallpaper file

    [ -d $XDG_DATA_HOME/a/media/images/wallpaper ] || \
	mkdir -p $XDG_DATA_HOME/a/media/images/wallpaper

    #cp $XDG_DATA_HOME/media/images/wallpaper/preferred-image.png $XDG_DATA_HOME/media/images/wallpaper/active
}


pacman_conf ()
{
    # disabling offline repo
    sudo sed -i '/^\[offline\]/ s/./#&/' $file_etc_pacman_conf
    sudo sed -i '/^Server = file:\/\// s/./#&/' $file_etc_pacman_conf

    # enabling original repositories
    sudo sed -i 's/^#X--//' $file_etc_pacman_conf

    # whenever network is available do:
    #sudo pacman -Syy
}


finishing_up ()
{
    # finishing

    ## administration
    sudo touch $HOME/hajime/5dtcf.done


    echo 'finished installation'
    read -p "sudo reboot? (Y/n) " -n 1 -r reply

    if [[ $reply =~ ^[Nn]$ ]] ; then

	exit

    else

	sudo reboot

    fi
}


main ()
{
    sourcing
    getargs $args
    get_offline_repo
    get_offline_code
    get_git_repo
    #dotfbu_restore
    rewrite_symlinks
    set_permissions
    z_shell_config
    set_sway_hardware
    base16
    qutebrowser
    #wallpaper
    pacman_conf
    finishing_up
}

main
