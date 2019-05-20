#!/bin/sh
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


clear


# make /usr read-write
sudo mount -o remount,rw  /usr


# dotfiles

## remove existing ~/.dot
rm -rf ~/.dot

## clone cytopyge dotfiles
[ -d ~/.dot ] || mkdir -p ~/.dot
git clone https://gitlab.com/cytopyge/dotfiles ~/.dot

## sourcing zsh shell
echo 'source ~/.dot/.zshrc' > ~/.zshrc

## sourcing vi improved
echo 'source ~/.dot/.vimrc' > ~/.vimrc

## sourcing tmux config
echo 'source ~/.dot/.tmuxrc' > ~/.tmux.conf

## restore dotfiles symlinks
sh ~/.dot/symlinks/restore

## restore resets /usr to ro
sudo mount -o remount,rw  /usr

## prepare wallpaper file
[ -d ~/media_/images/wallpaper ] || mkdir -p ~/media_/images/wallpaper/active
touch ~/media_images/wallpaper/active
## to be replaced with preferred image


# X11 config
## only to prevent errors
#touch ~/.Xauthority


# URxvt extensions
## install urxvt-resize-font
## Ctrl -, +, =, ?
## config in ~/.dot/.zshrc
#yay -Syu --noconfirm urxvt-resize-font-git


# zsh shell config

## set zsh as default shell for current user
## re-login for changes to take effect
sudo usermod -s `whereis zsh | awk '{print $2}'` $(whoami)

## change shell
sudo chsh -s /bin/zsh

## shell decoration
## base16
git clone https://github.com/chriskempson/base16-shell.git ~/.config/base16-shell
cd ~
base16_irblack


# vim

## vim alias
alias vim=nvim

## vim vundle
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim

## install plugins defined in ~/.dot/.vimrc
vim +PluginInstall +qall
clear


# global git configuration
git config --global user.email "$(whoami)@protonmail.com"
git config --global user.name "$(whoami)"


# mozilla firefox settings

mozilla_firefox() {

	[ -d ~/Downloads ] && rm -rf ~/Downloads
	[ -d ~/.mozilla ] && rm -rf ~/.mozilla
	git clone https://gitlab.com/cytopyge/ffxd_init ~/.mozilla
	## activate addons branch
	cd ~/.mozilla
	git checkout -f addons
	cd ~

}


mozilla_firefox


# prepare cytopyge git environment
[ -d ~/git ] || mkdir ~/git
cd ~/git


# recover public git repositories

## hajime
clear
git clone https://gitlab.com/cytopyge/hajime

## notes
clear
git clone https://gitlab.com/cytopyge/notes

## prepare system core code environment
[ -d ~/git/code ] || mkdir ~/git/code
cd ~/git/code

### bwsession
clear
git clone https://gitlab.com/cytopyge/bwsession

### updater
clear
git clone https://gitlab.com/cytopyge/updater

### isolatest
clear
git clone https://gitlab.com/cytopyge/isolatest


finishing_up() {

	# finishing

	## make all files in '~' owned by current user
	cd ~
	sudo chown -R $(whoami):wheel *

	## make /usr read-only
	sudo mount -o remount,ro  /usr

	## administration
	sudo touch ~/hajime/5dtcf.done


	clear
	echo 'finished installation'
	read -p "sudo reboot? (Y/n) " -n 1 -r

	if [[ $REPLY =~ ^[Nn]$ ]] ; then
		exit
	else
		sudo reboot
	fi

}


recover_cytopyge_private_git() {

	sh ~/git/code/bwsession/bwul

	#[TODO] wl-paste from sh script seems not to open vault properly

	## tried:
	## wl-paste
	## `echo wl-paste`
	wl-paste -n

	### netkill
	clear
	bw get item gitlab.com peacto | awk -F, '{print $13}' | awk -F: '{print $2}' | sed 's/"//g' | wl-copy -o

	git clone https://gitlab.com/cytopyge/netkill

	### hashr
	clear
	bw get item gitlab.com peacto | awk -F, '{print $13}' | awk -F: '{print $2}' | sed 's/"//g' | wl-copy -o

	git clone https://gitlab.com/cytopyge/hashr

	### wfa
	clear
	bw get item gitlab.com peacto | awk -F, '{print $13}' | awk -F: '{print $2}' | sed 's/"//g' | wl-copy -o

	git clone https://gitlab.com/cytopyge/wfa

	### snapshot
	clear
	bw get item gitlab.com peacto | awk -F, '{print $13}' | awk -F: '{print $2}' | sed 's/"//g' | wl-copy -o

	git clone https://gitlab.com/cytopyge/snapshot

	finishing_up

}


# recover private git repositories
clear
read -p "recover cytopyge private git repositories? (y/N) " -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]] ; then
	recover_cytopyge_private_git
else
	finishing_up
fi
