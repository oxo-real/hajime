#! /usr/bin/env sh

# system specific hajime installation configuration file

# CAUTION be sure all variables are 100% correct



# general

## debug switch [default,debug,debug_verbose]
exec_mode=default


# 0init

## debugging
hajime_src="/root/tmp/code/hajime"

## autostart next script
after_0init=1base


# 1base

## debugging
hajime_src="/root/tmp/code/hajime"
debug_log="${hajime_src}/1base-debug.log"

## boot partition
dev_boot=/dev/sda
part_boot=1
size_boot=+512M
type_boot=ef00
dev_boot_clear=clear

## lvm partition
dev_lvm=/dev/sda
part_lvm=2
size_lvm=+57G  ## 0 = until end of disk
type_lvm=8300
dev_lvm_clear=''

## lvm part sizes (GB)
size_root=1
size_home=10
size_tmp=1
size_usr=20
size_var=20

## swap partition size (GB)
swap_bool=yes
swap_size=4

## luks passphrase
luks_pass=luks

## autostart next script
after_1base=2conf


# 2conf

## debugging
hajime_src="/root/tmp/code/hajime"
debug_log="${hajime_src}/2conf-debug.log"

## user accounts
hostname=dl3189
root_pw=root
username=user
username_pw=user

## autostart next script
after_2conf=reboot


# 3post

## debugging
hajime_src="$HOME/dock/3/code/hajime"
debug_log="${hajime_src}/3post-debug.log"

## autostart next script
#after_3post=4apps


# 4apps

## debugging
hajime_src="$HOME/dock/3/code/hajime"
debug_log="${hajime_src}/4apps-debug.log"

## autostart next script
#after_4apps=5dtcf


# 5dotf

## debugging
hajime_src="$HOME/dock/3/code/hajime"
debug_log="${hajime_src}/5dtcf-debug.log"
