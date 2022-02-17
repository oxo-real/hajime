#!/usr/bin/env bash
#
##
###  _            _ _                      _ _        __
### | |__   __ _ (_|_)_ __ ___   ___    __| | |_ ___ / _|
### | '_ \ / _` || | | '_ ` _ \ / _ \  / _` | __/ __| |_
### | | | | (_| || | | | | | | |  __/ | (_| | || (__|  _|
### |_| |_|\__,_|/ |_|_| |_| |_|\___|  \__,_|\__\___|_| 5
###            |__/
###  _ _|_ _ ._    _  _
### (_\/|_(_)|_)\/(_|(/_
###   /      |  /  _|
###
### hajime_5dtcf
### grande finale fifth and last part
### cytopyge arch linux installation 'dotfiles configuration'
### copyright (c) 2019 - 2022  |  cytopyge
###
### GNU GPLv3 GENERAL PUBLIC LICENSE
### This file is part of hajime.
###
### Hajime is free software: you can redistribute it and/or modify
### it under the terms of the GNU General Public License as published by
### the Free Software Foundation, either version 3 of the License, or
### (at your option) any later version.
###
### This program is distributed in the hope that it will be useful,
### but WITHOUT ANY WARRANTY; without even the implied warranty of
### MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
### GNU General Public License for more details.
###
### You should have received a copy of the GNU General Public License
### along with this program.  If not, see <https://www.gnu.org/licenses/>.
### https://www.gnu.org/licenses/gpl-3.0.txt
###
### y3l0b3b5z2u=:matrix.org @cytopyge@mastodon.social
###
##
#

## dependencies
#	arch installation

## usage
#	sh hajime/5dtcf.sh

## example
#	none


# initial definitions

## script
script_name="5dtcf.sh"
developer="cytopyge"
licence='gplv3'

## hardcoded variables
# user customizable variables

## offline installation
offline=1
code_dir="/home/$(id -un)/dock/3"
repo_dir="/home/$(id -un)/dock/2"
repo_re="\/home\/$(id -un)\/dock\/2"
file_etc_pacman_conf='/etc/pacman.conf'

## main xdg locations
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_LOGS_HOME="$HOME/.logs"
export XDG_CONFIG_DIRS="/etc/xdg"

## main git locations
git_local="$XDG_DATA_HOME/c/git"
git_remote_gl="https://gitlab.com/cytopyge"
git_remote_cb="https://codeberg.org/cytopyge"
git_remote=$git_remote_cb

#--------------------------------


git_clone_dotfiles()
{
	# remove existing ~/.dot
	rm -rf ~/.dot
	[ -d "$HOME/.dot" ] || mkdir -p $HOME/.dot

	repo="dotfiles"
	local_dir=".dot"
	git clone $git_remote/$repo $HOME/$local_dir
}


git_clone_code()
{
	git_code="$git_local/code"
	#[ -d "$git_code" ] || mkdir -p $git_code

	### sources
	repo="sources"
	git clone $git_remote/$repo $git_code/$repo

	### tools
	repo="tools"
	git clone $git_remote/$repo $git_code/$repo

	### hajime
	repo="hajime"
	git clone $git_remote/$repo $git_code/$repo
	#### git/hajime becomes the git repo;
	#### remove git repo from install directory
	mv $HOME/hajime/.git $HOME/hajime/.git.DEL

	### isolatest
	repo="isolatest"
	git clone $git_remote/$repo $git_code/$repo

	### metar
	repo="metar"
	git clone $git_remote/$repo $git_code/$repo

	### netconn
	repo="netconn"
	git clone $git_remote/$repo $git_code/$repo

	### updater
	repo="updater"
	git clone $git_remote/$repo $git_code/$repo
}


git_clone_notes()
{
	repo="notes"
	git clone $git_remote/$repo $git_local/$repo
}


git_clone_private()
{
	#[TODO] check name
	repo="private"
	git clone $git_remote/$repo $git_local/$repo
}


get_public_data()
{
	if [[ $offline -ne 1 ]]; then

		git_clone_dotfiles
		git_clone_code
		git_clone_notes

	elif [[ $offline -eq 1 ]]; then

		home_dir_dst="$HOME"
		git_dir_dst="$XDG_DATA_HOME/c/git"

		[[ -d $home_dir_dst/.config ]] || mkdir -p	$home_dir_dst/.config
		[[ -d $git_dir_dst/code ]] || mkdir -p		$git_dir_dst/code
		[[ -d $git_dir_dst/notes ]] || mkdir -p		$git_dir_dst/notes

		printf "copying system configuration files... "
		cp -pr $code_dir/.config	$home_dir_dst
		printf "done\n"
		printf "copying code repository... "
		cp -pr $code_dir/code		$git_dir_dst
		printf "done\n"
		printf "copying notes repository... "
		cp -pr $code_dir/notes		$git_dir_dst
		printf "done\n"

	fi
}


get_private_data()
{
	if [[ $offline -ne 1 ]]; then

		git_clone_private

	elif [[ $offline -eq 1 ]]; then

		home_dir_dst="$HOME"
		git_dir_dst="$XDG_DATA_HOME/c/git"

		[[ -d $git_dir_dst/private ]] || mkdir -p	$git_dir_dst/private

		printf "copying private repository... "
		cp -pr $code_dir/private	$git_dir_dst
		printf "done\n"

	fi
}


run_dotbu()
{
	if [[ $offline -ne 1 ]]; then

		# restore .config from .dot
		sh $XDG_DATA_HOME/git/code/tools/dotbu restore $HOME/.dot/files $XDG_CONFIG_HOME

	fi
}


rewrite_symlinks()
{
	# rewrite symlinks in shln to current users home

	## create symlinks
	### create symlink to pass_vault mountpoint (vlt_pass)
	ln -s $HOME/dock/vlt/pass $HOME/.password-store

	## change symlinks
	### change config_shln
	sh $XDG_DATA_HOME/c/git/code/tools/chln
	### change network_ua
	sh $XDG_DATA_HOME/c/git/code/tools/chln $XDG_CONFIG_HOME/network/ua
}


set_permissions()
{
	# set right permissions for gnupg home
	sh $XDG_DATA_HOME/c/git/notes/crypto/gpg/gnupg_set_permissions
}


z_shell_config()
{
	## symlink in etc_zsh to zshenv
	sudo ln -s $XDG_CONFIG_HOME/zsh/etc_zsh_zshenv /etc/zsh/zshenv

	## set zsh as default shell for current user
	## re-login for changes to take effect
	sudo usermod -s `whereis zsh | awk '{print $2}'` $(whoami)

	## change shell
	sudo chsh -s /bin/zsh

	## enable command history
	[[ -d "$XDG_LOGS_HOME/history" ]] || mkdir $XDG_LOGS_HOME/history
	touch $XDG_LOGS_HOME/history/history
}


base16()
{
	if [[ $offline -ne 1 ]]; then

		## shell decoration
		## base16-shell
		git clone https://github.com/chriskempson/base16-shell.git $XDG_CONFIG_HOME/base16-shell

	elif [[ $offline -eq 1 ]]; then

		cp -pr $repo_dir/aur/base16-shell $XDG_CONFIG_HOME

	fi

	## set base16_irblack
	export BASE16_THEME=irblack
}


vim_plug()
{
	if [[ $offline -ne 1 ]]; then

		## vim plug
		sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
		       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

		## install plugins defined in: $XDG_CONFIG_HOME/nvim/plugins
		vim +PlugInstall +qall
		echo

	fi
}


mozilla_firefox()
{
	# mozilla firefox settings
	[ -d $HOME/Downloads ] && rm -rf $HOME/Downloads
	[ -d $HOME/.mozilla ] && rm -rf $HOME/.mozilla
}


wallpaper()
{
	# prepare wallpaper file

	[ -d $XDG_DATA_HOME/media/images/wallpaper ] || \
		mkdir -p $XDG_DATA_HOME/media/images/wallpaper
	## to be replaced with preferred image
	#cp $XDG_DATA_HOME/media/images/wallpaper/image.png $XDG_DATA_HOME/media/images/wallpaper/active
}


pacman_conf()
{
	# disbling offline repo
	sudo sed -i '/^\[offline\]/ s/./#&/' $file_etc_pacman_conf
	sudo sed -i '/^Server = file:\/\// s/./#&/' $file_etc_pacman_conf

	# enabling original repositories
	sudo sed -i 's/^#X--//' $file_etc_pacman_conf

	# when internet is available do:
	#sudo pacman -Syy
}


identify_io()
{
	#[TODO] see config_sway_dev
	:
}

finishing_up()
{
	# finishing

	## administration
	sudo touch ~/hajime/5dtcf.done


	echo 'finished installation'
	read -p "sudo reboot? (Y/n) " -n 1 -r

	if [[ $REPLY =~ ^[Nn]$ ]] ; then
		exit
	else
		sudo reboot
	fi
}


main()
{
	get_public_data
	get_private_data
	run_dotbu
	rewrite_symlinks
	set_permissions
	z_shell_config
	mozilla_firefox
	base16
	vim_plug
	wallpaper
	pacman_conf
	finishing_up
}

main
