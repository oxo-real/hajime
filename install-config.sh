#! /usr/bin/env sh
# hajime installation configuration file


# 0init


# 1base

## devices & partitioning 
dev_boot=/dev/sda; part_boot="$dev_boot"1
dev_lvm=/dev/sda; part_lvm="$dev_lvm"2
dev_key=/dev/sda; part_key="$dev_key"3

## swap (GB)
swap_bool=yes
swap_size=4

## boot (MB)
size_boot=256

## part sizes (GB)
size_root=1
size_tmp=1
size_usr=20
size_var=20
size_home=10


# 2conf


# 3post


# 4apps


# 5dotf
