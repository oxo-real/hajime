#! /usr/bin/env sh

# manually entering luks encrypted archlinux system:
# boot archiso
# set parameters
# then run this file

# this script:
# sets up an existing installation in a chroot jail (/mnt)
# for maintenance and/or recovery


# device parameters

## boot
dev_boot=dev/sda
part_boot=1
boot_part="$dev_boot""$part_boot"

## lvm
dev_lvm=/dev/sda
part_lvm=2
lvm_part="$dev_lvm""$part_lvm"


# cryptoluks parameters

## cryptoluks source
device_mapper=cryptlvm

## device mapper directory
map_dir=/dev/mapper


# logical volume manager parameters

## group name
vol_grp_name=vg0
logic_vol="$vol_grp_name"-lv

## lvm root mountpoint 
lvm_root=/mnt


# script

## create system directories
mkdir -p "$lvm_root"/{boot,home,tmp,usr,var}

## decrypt lvm container
cryptsetup open "$lvm_part" "$device_mapper"


## mount volume group
mount "$map_dir"/"$logic_vol"_root "$lvm_root"

## mount logical volumes
mount "$boot_part" "$lvm_root"/boot
mount "$map_dir"/"$logic_vol"_home "$lvm_root"/home
mount "$map_dir"/"$logic_vol"_tmp "$lvm_root"/tmp
mount "$map_dir"/"$logic_vol"_usr "$lvm_root"/usr
mount "$map_dir"/"$logic_vol"_var "$lvm_root"/var

## enter chroot jail (/mnt)
arch-chroot "$lvm_root"
