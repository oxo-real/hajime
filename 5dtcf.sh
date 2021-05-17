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
### (c) 2019 cytopyge
###
##
#


repo="https://gitlab.com/cytopyge"

# make /usr read-write
sudo mount -o remount,rw  /usr


# dotfiles

## remove existing ~/.dot
rm -rf ~/.dot

## clone cytopyge dotfiles
[ -d ~/.dot ] || mkdir -p ~/.dot
git clone $repo/dotfiles ~/.dot

## sourcing zsh shell
echo 'source ~/.dot/.zshrc' > ~/.zshrc

## sourcing vi improved
#echo 'source ~/.dot/.vimrc' > ~/.vimrc

## sourcing tmux config
#echo 'source ~/.dot/.tmuxrc' > ~/.tmux.conf

## restore dotfiles symlinks
sh ~/.dot/symlinks/restore

## restore resets /usr to ro
sudo mount -o remount,rw  /usr

## prepare wallpaper file
[ -d $XDG_DATA_HOME/media/images/wallpaper ] || \
	mkdir -p $XDG_DATA_HOME/media/images/wallpaper
## to be replaced with preferred image
#cd ~/_media/images/wallpaper
#mv image.png active
cd


# X11 config
## only to prevent errors
#touch ~/.Xauthority


# URxvt extensions
## install urxvt-resize-font
## Ctrl -, +, =, ?
## config in ~/.dot/.zshrc
#yay -Syu --noconfirm urxvt-resize-font-git


# pass
## create password-store symlink to pass_vault mountpoint
cd
ln -s $HOME/dock/vault .password-store


# zsh shell config

## set zsh as default shell for current user
## re-login for changes to take effect
sudo usermod -s `whereis zsh | awk '{print $2}'` $(whoami)

## change shell
sudo chsh -s /bin/zsh

## shell decoration
## base16-shell
git clone https://github.com/chriskempson/base16-shell.git $XDG_CONFIG_HOME/base16-shell
cd
base16_irblack


# vim

## vim plug
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

## install plugins defined in: $XDG_CONFIG_HOME/nvim/plugged
vim +PlugInstall +qall
echo


# global git configuration
## affects ~/.gitconfig
git config --global user.email "$(whoami)@protonmail.com"
git config --global user.name "$(whoami)"


# mozilla firefox settings

mozilla_firefox() {

	[ -d ~/Downloads ] && rm -rf ~/Downloads
	[ -d ~/.mozilla ] && rm -rf ~/.mozilla
	#git clone $repo/ffxd_init ~/.mozilla

	## activate addons branch
	#cd ~/.mozilla
	#git checkout -f addons
	#cd ~

}


mozilla_firefox


# prepare cytopyge git environment
[ -d $XDG_DATA_HOME/git ] || mkdir $XDG_DATA_HOME/git
cd $XDG_DATA_HOME/git


finishing_up() {

	# finishing

	## make /usr read-only
	sudo mount -o remount,ro  /usr

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


# recover public git repositories


## code

### prepare system core code environment
[ -d $XDG_DATA_HOME/git/code ] || mkdir $XDG_DATA_HOME/git/code
cd $XDG_DATA_HOME/git/code

### sources
git clone $repo/sources

### tools
git clone $repo/tools

### bwsession
git clone $repo/bwsession

### hajime
git clone $repo/hajime
#### git/hajime becomes the git repo;
#### remove git repo from install directory
rm -rf $HOME/hajime/.git

### isolatest
git clone $repo/isolatest

### metar
git clone $repo/metar

### netconn
git clone $repo/netconn

### tools
git clone $repo/tools

### updater
git clone $repo/updater

### notes
git clone $repo/notes

finishing_up
