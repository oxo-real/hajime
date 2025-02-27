#! /usr/bin/env sh


# after boot with liveiso, this script:
# sets up an existing installation for maintenance and/or recovery
# decrypts luks, setup lvm mountpoints and chroot into system


# device parameters

## boot
boot_part=dev/sda1

## cryptoluks source
crypt_dev=/dev/sdb
crypt_name=cryptlvm


# luks volume parameters

## group name
group_vol=vg0-lv

## mapper
dev_map=/dev/mapper

## mountpoint root
lvm_root=/mnt


# script

cryptsetup open "$crypt_dev" "$crypt_name"

mount "${dev_map}"/"${group_vol}"_root "${lvm_root}"
mount "${boot_part}" "${lvm_root}"/boot
mount "${dev_map}"/"${group_vol}"_tmp "${lvm_root}"/tmp
mount "${dev_map}"/"${group_vol}"_usr "${lvm_root}"/usr
mount "${dev_map}"/"${group_vol}"_var "${lvm_root}"/var
mount "${dev_map}"/"${group_vol}"_home "${lvm_root}"/home

arch-chroot "${lvm_root}"
