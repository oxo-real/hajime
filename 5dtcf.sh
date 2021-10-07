#!/bin/bash
#
##
###  _            _ _                      _ _        __
### | |__   __ _ (_|_)_ __ ___   ___    __| | |_ ___ / _|
### | '_ \ / _` || | | '_ ` _ \ / _ \  / _` | __/ __| |_
### | | | | (_| || | | | | | | |  __/ | (_| | || (__|  _|
### |_| |_|\__,_|/ |_|_| |_| |_|\___|  \__,_|\__\___|_| 5
###            |__/
###
###  _ _|_ _ ._    _  _
### (_\/|_(_)|_)\/(_|(/_
###   /      |  /  _|
###
### hajime_dtcf
### cytopyge arch linux installation 'dotfiles configuration'
### fifth and final part of a series
###
### (c) 2019 - 2021 cytopyge
###
##
#


repo="https://gitlab.com/cytopyge"

export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_LOGS_HOME="$HOME/.logs"
export XDG_CONFIG_DIRS="/etc/xdg"


git_clone_dotfiles()
{
	# remove existing ~/.dot
	rm -rf ~/.dot

	# prepare system core code environment
	[ -d $HOME/.dot/files ] || mkdir -p $HOME/.dot

	## clone dotfiles
	git clone $repo/dotfiles $HOME/.dot
}


git_clone_code()
{
	# prepare system core code environment
	[ -d $XDG_DATA_HOME/git/code ] || mkdir -p $XDG_DATA_HOME/git

	## clone code
	git_code="$XDG_DATA_HOME/git/code"

	### sources
	git clone $repo/sources $git_code

	### tools
	git clone $repo/tools $git_code

	### hajime
	git clone $repo/hajime $git_code
	#### git/hajime becomes the git repo;
	#### remove git repo from install directory
	mv $HOME/hajime/.git $HOME/hajime/.was.git

	### isolatest
	git clone $repo/isolatest $git_code

	### metar
	git clone $repo/metar $git_code

	### netconn
	git clone $repo/netconn $git_code

	### tools
	git clone $repo/tools $git_code

	### updater
	git clone $repo/updater $git_code
}


git_clone_notes()
{
	## clone notes
	git clone $repo/notes $XDG_DATA_HOME/git
}


git_clone_dotfiles
git_clone_code
git_clone_notes


# restore .config from .dot
sh $XDG_DATA_HOME/git/code/tools/dotbu restore $HOME/.dot/files $XDG_CONFIG_HOME


# zsh shell config

## sourcing zsh shell
echo 'source ~/.config/zsh/.zshrc' > ~/.zshrc

## set zsh as default shell for current user
## re-login for changes to take effect
sudo usermod -s `whereis zsh | awk '{print $2}'` $(whoami)

## change shell
sudo chsh -s /bin/zsh

## shell decoration
## base16-shell
#[TODO] create source variable on top of file
#git clone https://github.com/chriskempson/base16-shell.git $XDG_CONFIG_HOME/base16-shell
#cd
#base16_irblack


# vim

## vim plug
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

## install plugins defined in: $XDG_CONFIG_HOME/nvim/plugins
vim +PlugInstall +qall
echo


# global git configuration

## affects ~/.gitconfig
git config --global user.email "$(whoami)@protonmail.com"
git config --global user.name "$(whoami)"


# pass

## create password-store symlink to pass_vault mountpoint
cd
ln -s $HOME/dock/vault .password-store


# mozilla firefox settings

mozilla_firefox()
{
	[ -d ~/Downloads ] && rm -rf ~/Downloads
	[ -d ~/.mozilla ] && rm -rf ~/.mozilla
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
