#! /usr/bin/env sh

# forst boot archiso
# CAUTION root will have escalated privileges
# NOTICE specific for oxo linux distribution

# to set up an existing installation in a chroot jail (/mnt)
# for maintenance and/or recovery, run:
# % rescue.sh --open
# when done:
# % rescue.sh --close


#TODO verify if we are chroot jailed:
# [linux - Detecting a chroot jail from within - Stack Overflow](https://stackoverflow.com/questions/75182/detecting-a-chroot-jail-from-within)
# ! [ -x /proc/1/root/. ] || [ /proc/1/root/. -ef / ]

# device parameters

## boot
# dev_boot=/dev/sda
# part_boot=1
# boot_part="$dev_boot""$part_boot"

## lvm
# dev_lvm=/dev/sda
# part_lvm=2
# lvm_part="$dev_lvm""$part_lvm"


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


args="$@"


get_devices ()
{
    lsblk -paf
    echo
    boot_part=$(lsblk -paf --raw | grep BOOT | awk '{print $1}')
    lsblk -paf | grep "$boot_part"
    echo
    lvm_part=$(lsblk -paf --raw | grep crypto_LUKS | awk '{print $1}')
    lsblk -paf | grep "$lvm_part"

    printf 'correct? [y/N] '
    read -r reply

    if [[ ! "$reply" =~ ^[yY]$ ]]; then

	exit 66

    fi
}


# script
os_open ()
{
    ## decrypt lvm container
    cryptsetup open "$lvm_part" "$device_mapper"

    ## activate volumegroup
    vgchange --activate y "$vol_grp_name"

    ## mount volume group to root mountpoint
    mount "$map_dir"/"$logic_vol"_root "$lvm_root"

    ## mount logical volumes (submounts)
    mount "$boot_part" "$lvm_root"/boot
    mount "$map_dir"/"$logic_vol"_home "$lvm_root"/home
    mount "$map_dir"/"$logic_vol"_tmp "$lvm_root"/tmp
    mount "$map_dir"/"$logic_vol"_usr "$lvm_root"/usr
    mount "$map_dir"/"$logic_vol"_var "$lvm_root"/var

    ## enter chroot jail (/mnt)
    arch-chroot "$lvm_root"
}


os_close ()
{
    ## exit chroot jail (/mnt)
    ## NOTICE manually exit with:
    ## exit
    ## thereafter run rescue.sh --close

    ## unmount root mountpoint with submounts
    umount -R "$lvm_root"

    ## deactivate volume group
    vgchange --activate n "$vol_grp_name"

    ## close luks container
    cryptsetup close "$device_mapper"
}


main ()
{
    get_devices
    [[ "$args" == '--open' ]] && os_open
    [[ "$args" == '--close' ]] && os_close
}

main
