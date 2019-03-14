#!/bin/bash
#
##
###  _            _ _                        _ _         
### | |__   __ _ (_|_)_ __ ___   ___    __ _(_) |_ _   _ 
### | '_ \ / _` || | | '_ ` _ \ / _ \  / _` | | __| | | |
### | | | | (_| || | | | | | | |  __/ | (_| | | |_| |_| |
### |_| |_|\__,_|/ |_|_| |_| |_|\___|  \__, |_|\__|\__,_|7
###            |__/                    |___/             
###
###  _ _|_ _ ._    _  _  
### (_\/|_(_)|_)\/(_|(/_ 
###   /      |  /  _|                      
###
### hajime_logr
### cytopyge arch linux installation 'update git repository'
### addendum to a five part installation series
###
### (c) 2019 cytopyge
###
## 
#


# prepare git environment
[ -d ~/git ] || mkdir ~/git
cd ~/git


# recover public git repositories

## hajime
git clone https://gitlab.com/cytopyge/hajime

## notes
git clone https://gitlab.com/cytopyge/notes

## prepare system core code environment
[ -d ~/git/code ] || mkdir ~/git/code
cd ~/git/code

### wfkill
git clone https://gitlab.com/cytopyge/wfkill

### bwsession
git clone https://gitlab.com/cytopyge/bwsession

### linup
git clone https://gitlab.com/cytopyge/linup


# recover private git repositories
while true; do
	read -p "recover private git repositories? (y/n) " private
    case $private in
        [Yy]* ) sh ~/git/code/bwsession/bwul; break;;
        [Nn]* ) exit;;
	* ) echo "(y/n)?";;
    esac
done

#[TODO] wl-paste from bash script seems not to open vault properly
## tried:
## wl-paste
## `echo wl-paste`
wl-paste -n

### hashr
bw get item gitlab.com peacto | awk -F, '{print $13}' | awk -F: '{print $2}' | sed 's/"//g' | wl-copy -o

git clone https://gitlab.com/cytopyge/hashr

### wfa
bw get item gitlab.com peacto | awk -F, '{print $13}' | awk -F: '{print $2}' | sed 's/"//g' | wl-copy -o

git clone https://gitlab.com/cytopyge/wfa

### snapshot 
bw get item gitlab.com peacto | awk -F, '{print $13}' | awk -F: '{print $2}' | sed 's/"//g' | wl-copy -o

git clone https://gitlab.com/cytopyge/snapshot


# make all files in '~' owned by current user
cd ~
sudo chown -R cytopyge:wheel *


clear
echo 'finished installation'
echo 'please reboot'
