#!/bin/bash
#
##
###  _            _ _                      _       _   _ 
### | |__   __ _ (_|_)_ __ ___   ___    __| | ___ | |_(_)
### | '_ \ / _` || | | '_ ` _ \ / _ \  / _` |/ _ \| __| |
### | | | | (_| || | | | | | | |  __/ | (_| | (_) | |_| |
### |_| |_|\__,_|/ |_|_| |_| |_|\___|  \__,_|\___/ \__|_|5
###            |__/                                      
###
###  _ _|_ _ ._    _  _  
### (_\/|_(_)|_)\/(_|(/_ 
###   /      |  /  _|                                               
###
### hajime_doti
### cytopyge arch linux installation 'dotfiles installation and configuration'
### fifth and final part of a series
###
### (c) 2019 cytopyge
###
##
#


# make /usr read-write
sudo mount -o remount,rw  /usr


####### ###### #### ### ## # FOR DEVELOPMENT PURPOSES # ## ### #### ##### ######
## update hajime
#sudo rm -rf hajime
#sudo dhcpcd enp0s3
#git clone https://gitlab.com/cytopyge/hajime
####### ###### #### ### ## # FOR DEVELOPMENT PURPOSES # ## ### #### ##### ######


# dotfiles

## removing existing ~/.dot
rm -rf ~/.dot

## clone cytopyge dotfiles
[ -d ~/.dot ] || mkdir -p ~/.dot
git clone -q https://gitlab.com/cytopyge/dotfiles ~/.dot


# sourcing dotfiles

## zsh shell
echo 'source ~/.dot/.zshrc' > ~/.zshrc

## vi improved
echo 'source ~/.dot/.vimrc' > ~/.vimrc


# restore dotfiles symlinks
sh ~/.dot/symlinks/restore


# restore resets /usr to ro
sudo mount -o remount,rw  /usr


# X11 config
## only to prevent errors
#touch ~/.Xauthority


# URxvt extensions
## install urxvt-resize-font
## Ctrl -, +, =, ?
## config in ~/.dot/.zshrc
#yay -Syu --noconfirm urxvt-resize-font-git


# install bitwarden-cli config
yay -S --noconfirm bitwarden-cli

## clone bwsession (padding & bwul)
[ -d ~/git/code/bwsession ] || mkdir -p ~/git/code
git clone -q https://gitlab.com/cytopyge/bwsession ~/git/code/bwsession


# encryption
yay -S --noconfirm veracrypt

# vpn 
yay -S --noconfirm openvpn wireguard-tools


# zsh shell config

## set zsh as default shell for current user
## re-login for changes to take effect
sudo usermod -s `whereis zsh | awk '{print $2}'` $(whoami)

## ZSH completions
yay -S --noconfirm zsh-completions

##ZSH syntax highlighting
yay -S --noconfirm zsh-syntax-highlighting

## change shell
sudo chsh -s /bin/zsh


## base16
git clone https://github.com/chriskempson/base16-shell.git ~/.config/base16-shell
base16_irblack


# vim vundle
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim

## install plugins defined in ~/.dot/.vimrc
vim +PluginInstall +qall


# global git configuration
git config --global user.email "$(whoami)@protonmail.com"
git config --global user.name "$(whoami)"


# finishing

## make /usr read-only
sudo mount -o remount,ro  /usr

## administration
sudo touch ~/hajime/5doti.done

clear
echo 'sh hajime/6apps.sh'
