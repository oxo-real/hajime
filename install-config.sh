#! /usr/bin/env sh

# system specific hajime installation configuration file


# 0init
# novars

# 1base

## devices & partitioning 
## boot
dev_boot=/dev/sda
part_boot=1
size_boot=+256M
type_boot=ef00
dev_boot_clear='clear'

## lvm
dev_lvm=/dev/sda
part_lvm=2
size_lvm=0  ## 0 = until end of disk
type_lvm=8300
dev_lvm_clear=''

## lvm part sizes (GB)
size_root=1
size_home=10
size_tmp=1
size_usr=20
size_var=20

## swap (GB)
swap_bool=yes
swap_size=4

## luks passphrase
luks_pass=luks

# 2conf
hostname=dl3189
root_pw=root
username=user
username_pw=user


# 3post
# novars

# 4apps
# novars


# 5dotf
# novars
