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

# overview
--------------------------------

# hajime
2019 - 2022  |  cytopyge

When the right preparations are made this installation script installs an up-to-date Arch Linux system on an x64 architecture.

## a five part arch linux installation series

### 1  Base
The 'base' script creates a Globally Unique Identifiers (GUID) partition table (GPT) and Unified Extensible Firmware Interface (UEFI) system partition with systemd boot to bootstrap the user space for bleeding edge (BLE) and long term support (LTS) arch linux kernel.

BOOT (ro) can and is recommended to be a separate device partition and physical separate storage medium. Logical volume manager (LVM) is fully encrypted with Linux Unified Key Setup (LUKS2) and contains the separate volume partitions ROOT, USR (ro), VAR (ro), HOME and SWAP (optional).

### 2  Conf
The 'conf' script configures settings for time, network, mirrorlists, bootloader entries for bleeding edge and long term support kernels, ramdisk and creates an user environment.

After execution of 'conf' the system is able to boot independently.

### 3  Post
The third script prepares the system 'post install' for the installation of a desktop environment.

Modifications are made to the package manager, the entire operating system is updated, a mountpoint environment is beig created and an alternative AUR manager can be installed alongside the native 'pacman'.

After execution of 'post' an fully fledged Arch Linux installation is running on the system.

### 4  Apps
'hajime apps' prepares the system for a display manager running under Wayland, with wlroots as a modular compositor library.

The script will setup the Sway tiling window manager, but it can easily be modifed to be setup for X11 based managers, when preferred.

It also installs a variety of tools, among others for: video, text, file management, network management, internet, system monitoring, virtual environments.

### 5  Dtcf
'dtcf' installs the dotfile configuration, which contains settings for the apps and window manager to run smoothly.


# requirements
--------------------------------

## hardware

### REQUIRED	host machine
An (Arch) Linux machine, in order to be able to copy an offline repository.

The host machine must have an internet connection.

	*	operating system		archlinux
	*	network					internet access

### REQUIRED	target machine
Arch Linux is expected to run on almost every contemporary computer.

The (minimum) requirements are:

	*	architecture			x86-64	(or compatible)
	*	storage capacity		>=	2G
	*	RA memory				>=	512M

### REQUIRED	usb1 archiso
An empty data storage device with a size of at least 5G to install the Arch Linux Installer.

	*	usb1					>=	5G

### REQUIRED	usb2 repocode
An empty data storage device with a recommended size of at least 20G storage capacity.

The exact required size is heavily customizable and depends on which (and how many versions of)

packages are copied from the host machine.

	*	usb2					>=	20G

### OPTIONAL	usb3 boot
Optional, but a privacy recommendation, is a separate boot device. It does not to be big.

	*	usb3					>=	256M

## software

### REQUIRED	archlinux iso
In order to boot the live environment, from where hajime will be ran,

we need the archlinux installation image.

	*	archiso					https://www.archlinux.org/download/

### OPTIONAL	isolatest
Use isolatest to automatically download the iso image, verify signatures and prepare archiso.

Download it from the internet via Codeberg (recommended) or Gitlab.

	* isolatest					https://codeberg.org/cytopyg3/isolatest
								https://gitlab.com/cytopyge/isolatest


### REQUIRED	hajime
The installer script itself.

Download it from the internet via Codeberg (recommended) or Gitlab.

	* hajime					https://codeberg.org/cytopyg3/hajime
								https://gitlab.com/cytopyge/hajime

###	OPT / REQ	network
For the preparation phase an internet connection is required.

During installation an internet connection is optional

# step-by-step guide

# preparation
--------------------------------

The preparation phase is executed on the host machine.

enter and execute code after '%' sign on your own host machine

## 01
Connect a host machine to the internet.

install git if it is not already done so
```
% sudo pacman -S git
```

download isolatest via codeberg:
```
% git clone https://codeberg.org/cytopyg3/isolatest
```


CAUTION!
{values} between curly braces are specific and volatile!

be sure to take the right one in your case!

i.e. /dev/sd{RC1} can be /dev/sdc1

## 02
insert usb1

CAUTION! DESIGNATE THE RIGHT DEVICE!

WARNING! ALL DATA WILL BE DESTROYED!

designate (verify!) the device name of usb1

```
% lsblk -paf
```

## 03
execute isolatest

```
% sh isolatest /dev/sd{AI}
```

## 04
insert usb2

create an ext4 partition labeled REPO

CAUTION! DESIGNATE THE RIGHT DEVICE!

WARNING! ALL DATA WILL BE DESTROYED!

```
% sudo gdisk /dev/sd{RC}
```

enter:	o	to rewrite GPT table

		n	create a 10G 8300 partition (REPO)

		n	create a 10G 8300 partition (CODE)

		w	write changes to device

		q	quit gdisk

```
% sudo mkfs.ext4 -L REPO /dev/sd{RC2}
% sudo mkfs.ext4 -L CODE /dev/sd{RC3}
% mkdir dock/{2,3,3/code}
```

## 05
Prepare the CODE partition

```
% sudo mount /dev/sdR3 dock/3
```

download scripts from repository
```
% git clone https://codeberg.org/cytopyg3/hajime	dock/3/code/hajime
% git clone https://codeberg.org/cytopyg3/isolatest	dock/3/code/isolatest
% git clone https://codeberg.org/cytopyg3/netconn	dock/3/code/netconn
% git clone https://codeberg.org/cytopyg3/sources	dock/3/code/sources
% git clone https://codeberg.org/cytopyg3/tools		dock/3/code/tools
% git clone https://codeberg.org/cytopyg3/updater	dock/3/code/updater
```

## 06
Prepare the REPO partition

```
% sudo mount /dev/sdR2 dock/2

% sh dock/3/code/tools/make_offl_repo dock/2
```

Preparation is now finished. We now have:

usb1	with archiso

usb2	with REPO and CODE partitions

usb3	optional boot stick


# installation
--------------------------------

The installation phase is executed on the target machine.

## 11
WARNING! ALL DATA ON TARGET MACHINE WILL BE DESTROYED!

switch the target machine off

insert usb1

switch the target machine on

## 12
after booting into archiso insert usb2

mount usb2 to tmp

```
% mkdir tmp
% lsblk -paf
```

CAUTION! DESIGNATE THE RIGHT DEVICE!

```
% mount /dev/sdX tmp
% sh tmp/code/hajime/0init.sh
```

hajime is primarily designed to run without internet connection

it is recommended to install entirely offline and connect to any network

not earlier than after the installation is fully completed.


## 13	start hajime
insert usb3 (optional)

let's roll!

```
% sh hajime/1base.sh
```

from here run the scripts in their numerical order:
	1base.sh
	2conf.sh
	3post.sh
	4apps.sh
	5dtcf.sh

CAUTION! READ AND EXECUTE THE ON-SCREEN INSTRUCTIONS THOROUGHLY!

the system reboots after 2conf has been executed

CAUTION! REMOVE USB1 BEFORE REBOOTING!


## install log
--------------------------------
For debug purposes it can be useful to be able to review an logging of the installation process.
Create a full debug log of the installation with:

```
sh hajime/1base.sh | tee hajime/1base.log
```

After execution of the 1base.sh script is finished, copy the log file to the arch-chroot environment:

```
mv /root/hajime/1base.log /mnt/hajime/1base.log
```

The log of the second script can be directly written in de arch-chroot environment:

```
sh hajime/2conf.sh | tee /mnt/hajime/2conf.log
```

From the third script the installation process is running inside the operating system environment,
therefore logs can be written to the home folder of the current user:

```
sh hajime/3post.sh | tee $HOME/hajime/3post.log
```

Be aware of the fact that writing to debug logs can cause some troubles with proper execution of the installation scripts.


# resource reference
--------------------------------

## general installation guide
* https://wiki.archlinux.org/index.php/installation_guide

## post install recommendations
* https://wiki.archlinux.org/index.php/General_recommendations

## partitioning
* https://wiki.archlinux.org/index.php/Partitioning

## UEFI
* https://wiki.archlinux.org/index.php/EFI_System_Partition

## ramfs
* https://wiki.archlinux.org/index.php/Mkinitcpio

## encryption
* https://wiki.archlinux.org/index.php/Dm-crypt/Encrypting_an_entire_system

## LUKS2
* https://gitlab.com/cryptsetup/LUKS2-docs

## LVM
* https://wiki.archlinux.org/index.php/LVM
* https://wiki.archlinux.org/index.php/Resizing_LVM-on-LUKS

## systemd
* https://freedesktop.org/wiki/Software/systemd

## Wayland
* https://wayland.freedesktop.org
* https://github.com/swaywm/wlroots

## Sway
https://swaywm.org/

## inspirations
among others:
* https://github.com/budlabs
* https://github.com/christoomey
* https://github.com/gotbletu
* https://github.com/kaihendry
* https://github.com/lukesmithxyz
* https://github.com/r00k
* https://github.com/tpope

 thanks for sharing!

## more inspirational
* https://www.fsf.org/
* http://www.gnu.org/
