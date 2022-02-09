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
###
### 2019 - 2022  |  cytopyge
###
##
#


# user customizable variables

## offline installation
offline=1
code_dir="/home/$(id -un)/dock/3"
repo_dir="/home/$(id -un)/dock/2"
repo_re="\/home\/$(id -un)\/dock\/2"
file_etc_pacman_conf='/etc/pacman.conf'


export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_LOGS_HOME="$HOME/.logs"
export XDG_CONFIG_DIRS="/etc/xdg"

git_local="$XDG_DATA_HOME/c/git"
git_remote_gl="https://gitlab.com/cytopyge"
git_remote_cb="https://codeberg.org/cytopyge"
git_remote=$git_remote_cb

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
	[[ -d $git_dir_dst/provate ]] || mkdir -p	$git_dir_dst/private

	cp -pr $code_dir/.config	$home_dir_dst
	cp -pr $code_dir/code		$git_dir_dst
	cp -pr $code_dir/notes		$git_dir_dst
	cp -pr $code_dir/private	$git_dir_dst

fi


if [[ $offline -ne 1 ]]; then

	# restore .config from .dot
	sh $XDG_DATA_HOME/git/code/tools/dotbu restore $HOME/.dot/files $XDG_CONFIG_HOME

fi


# rewrite symlinks in shln to current users home
sh $XDG_DATA_HOME/git/code/tools/chln


# set right permissions for gnupg home
sh /home/cytopyge/.local/share/git/notes/crypto/gpg/gnupg_set_permissions


# zsh shell config

## sourcing zsh shell
echo 'source ~/.config/zsh/.zshrc' > ~/.zshrc

## set zsh as default shell for current user
## re-login for changes to take effect
sudo usermod -s `whereis zsh | awk '{print $2}'` $(whoami)

## change shell
sudo chsh -s /bin/zsh

## enable command history
[[ -d "$XDG_LOGS_HOME/history" ]] || mkdir $XDG_LOGS_HOME/history
touch $XDG_LOGS_HOME/history/history


## [WARNING] ## no offline alternative
#
if [[ $offline -ne 1 ]]; then

	## shell decoration
	## base16-shell
	#[TODO] create source variable on top of file
	git clone https://github.com/chriskempson/base16-shell.git $XDG_CONFIG_HOME/base16-shell
	cd
	## base16_irblack
	_base16 "/home/cytopyge/.config/base16-shell/scripts/base16-irblack.sh" irblack

fi

## [WARNING] ## no offline alternative
#
if [[ $offline -ne 1 ]]; then

	# vim

	## vim plug
	sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
	       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

	## install plugins defined in: $XDG_CONFIG_HOME/nvim/plugins
	vim +PlugInstall +qall
	echo

fi

# pass

## create password-store symlink to pass_vault mountpoint
cd
ln -s $HOME/dock/vlt/pass .password-store


# mozilla firefox settings

mozilla_firefox()
{
	[ -d $HOME/Downloads ] && rm -rf $HOME/Downloads
	[ -d $HOME/.mozilla ] && rm -rf $HOME/.mozilla
}

mozilla_firefox


# prepare wallpaper file

[ -d $XDG_DATA_HOME/media/images/wallpaper ] || \
	mkdir -p $XDG_DATA_HOME/media/images/wallpaper
## to be replaced with preferred image
#cp $XDG_DATA_HOME/media/images/wallpaper/image.png $XDG_DATA_HOME/media/images/wallpaper/active


finishing_up() {

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


finishing_up
