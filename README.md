```
 _            _ _
| |__   __ _ (_|_)_ __ ___   ___
| '_ \ / _` || | | '_ ` _ \ / _ \
| | | | (_| || | | | | | | |  __/
|_| |_|\__,_|/ |_|_| |_| |_|\___|
           |__/

 _ _|_ _ ._    _  _
(_\/|_(_)|_)\/(_|(/_
  /      |  /  _|

```
# hajime
## a five part arch linux installation series
(c) 2019 cytopyge

### 1  Base
The 'base' script creates a Globally Unique Identifiers (GUID) partition table (GPT) and Unified Extensible Firmware Interface (UEFI) system partition with systemd boot to bootstrap the user space for bleeding edge (BLE) and long term support (LTS) arch linux kernel. BOOT (ro) can be a separate partition / device. Logical volume manager (LVM) is fully encrypted with Linux Unified Key Setup (LUKS2) and contains separate volumes partitions for ROOT, HOME, VAR, USR (ro) and SWAP.

### 2  Conf
The 'conf' script configures settings for time, network, mirrorlists, bootloader entries for bleeding edge and long term support kernels, ramdisk and creates an user environment. After 'conf' the system is able to boot independently.

### 3  Post
The third script prepares the system 'post install' for the installation of a desktop environment. Modifications are made to the package manager, the entire operating system is updated, a mountpoint environment is beig created and an alternative AUR manager 'yay' is installed alongside the native 'pacman'. After 'post' an fully fledged Arch installation is running on the system.

### 4  Apps
'hajime apps' prepares the system for a display manager running under Wayland, with wlroots as a modular compositor library. The script will setup the Sway tiling window manager, but it can easily be modifed to be setup for X11 based managers, when preferred. It also installs a variety of tools, among others for: video, text, file management, network management, internet, system monitoring, virtual environments.

### 5  Dtcg
'dtcg' installs the dotfile configuration, which contains settings for the apps and window manager to run smoothly.


## Take off instructions
When using the 'hajime' scripts:
Be sure to first get your latest Arch Linux install image with isolatest (https://gitlab.com/cytopyge/isolatest) or manually via: https://www.archlinux.org/download/.
Boot into the ArchISO live system environment, install git, clone 'hajime' and check the user customizable variables sections before executing the first script:

```
pacman -Sy git
git clone https://gitlab.com/cytopyge/hajime
./hajime/1base.sh
```

From here run the scripts in numerical order and follow the in-script instructions. Have fun!

---
---

## install log
For debug purposes it can be useful to review an logging of the installation process.
Create a full debug log of the installation with:

```
sh -xv hajime/1base.sh | tee hajime/1base.log
```

After execution of the 1base.sh script is finished, copy the log file to the arch-chroot environment:

```
mv /hajime/1base.log /mnt/hajime/1base.log
```

The log of the second script can be directly written in de arch-chroot environment:

```
sh -xv hajime/2conf.sh | tee /mnt/hajime/2conf.log
```

From the third script the installation process is running inside the operating system environment,
therefore logs can be written to the home folder of the current user:

```
sh -xv hajime/3post.sh | tee $HOME/hajime/3post.log
```

# resource reference

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
* https://wiki.archlinux.org/index.php/LVM
* https://wiki.archlinux.org/index.php/Resizing_LVM-on-LUKS

## systemd
https://freedesktop.org/wiki/Software/systemd

## Wayland
* https://wayland.freedesktop.org
* https://github.com/swaywm/wlroots

## Sway
https://swaywm.org/

## rice inspirations
* https://github.com/budlabs
* https://github.com/lukesmithxyz
* https://github.com/kaihendry
* https://github.com/gotbletu
* https://github.com/tpope
* https://github.com/christoomey
* https://github.com/r00k

many thanks for sharing!

## more inspirational
* https://www.fsf.org/
* http://www.gnu.org/
