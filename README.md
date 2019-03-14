```
           _ _ 
  ___ __ _| (_)
 / __/ _` | | |
| (_| (_| | | |
 \___\__,_|_|_|
 _ _|_ _ ._    _  _  
(_\/|_(_)|_)\/(_|(/_ 
  /      |  /  _|    
```
# cytopyge arch linux installation
a seven part installation series
(c) 2019 cytopyge

## cali

### 1  Base
The 'base' script creates a Globally Unique Identifiers (GUID) partition table (GPT) and Unified Extensible Firmware Interface (UEFI) system partition with systemd boot to bootstrap the user space for bleeding edge (BLE) and long term support (LTS) arch linux kernel. BOOT (ro) can be a separate partition / device. Logical volume manager (LVM) is fully encrypted with Linux Unified Key Setup (LUKS2) and contains separate volumes partitions for ROOT, HOME, VAR, USR (ro) and SWAP.

### 2  Conf
The 'conf' script configures settings for time, network, mirrorlists, bootloader entries for bleeding edge and long term support kernels, ramdisk and creates an user environment.

### 3  Post
The third script creates 'post install' modifications to the package manager, updates the entire operating system, creates a mountpoint environment and installs an alternative AUR manager (yay) alongside pacman. After 'post' an fully fledged Arch installation is running on the system.

### 4  Rice
'cali rice' prepares the system for a display manager running under Wayland, with wlroots as a modular compositor library. The script will setup the Sway tiling window manager, but it can easily be modifed to be setup for old fashioned X11 based managers.

### 5  Doti
'doti' installs a personal configuration dotfiles and tools like: z shell, vim, bitwarden, veracrypt.

### 6  Apps
Installs a variety of tools, among others for: video, text, file management, network management, internet, system monitoring, virtual environments.

### 7  Logr
'logr' recovers personal local git repositorie. Adviced to tweak to personal preference.


## Take off instructions
when using these cali scripts:
be sure to get your latest Arch Linux image via: https://www.archlinux.org/download/
after booting archiso live environment manually install git, clone cali by executing:

```
pacman -Sy git
git clone https://gitlab.com/cytopyge/cali
./cali/base.sh
```

from here follow the in script instructions.

---
---

# resources

## general installation guide
https://wiki.archlinux.org/index.php/installation_guide

## post install recommendations
https://wiki.archlinux.org/index.php/General_recommendations

## partitioning
https://wiki.archlinux.org/index.php/Partitioning

## UEFI
https://wiki.archlinux.org/index.php/EFI_System_Partition

## ramfs
https://wiki.archlinux.org/index.php/Mkinitcpio

## encryption
https://wiki.archlinux.org/index.php/Dm-crypt/Encrypting_an_entire_system

## LUKS2
https://gitlab.com/cryptsetup/LUKS2-docs

## LVM
https://wiki.archlinux.org/index.php/LVM
https://wiki.archlinux.org/index.php/Resizing_LVM-on-LUKS

## systemd
https://freedesktop.org/wiki/Software/systemd

## Wayland
https://wayland.freedesktop.org

## Sway
https://github.com/swaywm/wlroots
https://swaywm.org/
