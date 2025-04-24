```
 _            _ _
| |__   __ _ (_|_)_ __ ___   ___
| '_ \ / _` || | | '_ ` _ \ / _ \
| | | | (_| || | | | | | | |  __/
|_| |_|\__,_|/ |_|_| |_| |_|\___|
           |__/

 # # # # # #
      #
 # # # # # #

```

# overview
--------------------------------

# hajime
copyright (c) 2017 - 2025  |  oxo

This installation script installs an Arch Linux system on an x64 architecture.
The installation can be done with or without a network connection (internet).

## a five part arch linux installation series

### 0 init
This script initializes the installation process, like copying files over to the machine and, if applicable, establishing an internet connection.

### 1  base
The 'base' script creates a Globally Unique Identifiers (GUID) partition table (GPT) and Unified Extensible Firmware Interface (UEFI) system partition with systemd boot to bootstrap the user space for latest stable release (LSR) and long term support (LTS) arch linux kernel.

BOOT (ro) can and is recommended to be a separate device partition and physical separate storage medium. Logical volume manager (LVM) is fully encrypted with Linux Unified Key Setup (LUKS2) and contains the separate volume partitions ROOT, TMP, USR (ro), VAR (ro), HOME and SWAP (optional).

### 2  conf
The 'conf' script configures settings for time, network, mirrorlists, bootloader entries for both latest stable release (LSR) and long term support (LTS) kernel, ramdisk and creates an user environment.

After execution of 'conf' the system is able to boot independently.

### 3  post
The third script prepares the system 'post install' for the installation of a desktop environment.

Modifications are made to the package manager, the entire operating system is updated, a mountpoint environment is beig created and an alternative AUR manager can be installed alongside the native 'pacman'.

After execution of 'post' an fully fledged Arch Linux installation is running on the system.

### 4  apps
'hajime apps' prepares the system for a display manager running under Wayland, with wlroots as a modular compositor library.

The script will setup the Sway tiling window manager, but it can easily be modifed to be setup for X11 based managers, when preferred.

It also installs a variety of tools, among others for: video, text, file management, network management, internet, system monitoring, virtual environments.

### 5  dtcf
'dtcf' installs the dotfile configuration, which contains settings for the apps and compositor (window manager) to run smoothly.


# requirements
--------------------------------

## hardware

### REQUIRED	host machine
An (Arch) Linux machine, in order to be able to copy an offline repository.

The host machine must have an internet connection.

	*	operating system	archlinux
	*	network				internet access

### REQUIRED	target machine
Arch Linux is expected to run on almost every contemporary computer.

The (minimum) requirements are:

	*	architecture		x86-64	(or compatible)
	*	storage capacity	>=	2G
	*	RA memory			>=	512M

### REQUIRED	usb1 archiso
An empty data storage device with a size of at least 5G to install the Arch Linux Installer.

	*	usb1				>=	5G

### REQUIRED	usb2 repocode
An empty data storage device with a recommended size of at least 20G storage capacity.

The exact required size is heavily customizable and depends on which (and how many versions of)

packages are copied from the host machine.

	*	usb2				>=	20G

### OPTIONAL	usb3 boot
Optional, though a security recommendation, is a separate boot device. It does not have to be big.

	*	usb3				>=	256M

## software

### REQUIRED	archlinux iso
In order to boot the live environment, from where hajime will be ran,

we need the archlinux installation image.

	*	archiso				https://www.archlinux.org/download/

### OPTIONAL	isolatest
Use isolatest to automatically download the iso image, verify signatures and prepare archiso.

Download it from the internet via codeberg.org/oxo (recommended) or gitlab.com/cytopyge.

	* isolatest				https://codeberg.org/oxo/isolatest
	                        https://gitlab.com/cytopyge/isolatest


### REQUIRED	hajime
The installer script itself.

Download it from the internet via codeberg.org/oxo (recommended) or gitlab.com/cytopyge.

	* hajime				https://codeberg.org/oxo/hajime
						    https://gitlab.com/cytopyge/hajime

###	OPT / REQ	network
For the preparation phase a network (internet) connection is required.

During installation a network (internet) connection is optional.

# step-by-step guide

# preparation
--------------------------------

The preparation phase is executed on the host machine.

Enter and execute code after the '%' sign on your own host machine;

## 01
Connect a host machine to the internet.

install git if it is not already done so
```
% sudo pacman -S git
```

git clone isolatest via codeberg.org (recommended):
```
% git clone https://codeberg.org/oxo/isolatest
```

or download files an other way, i.e. with curl
```
% curl --location --remote-name https://codeberg.org/oxo/isolatest/archive/main.zip -C -
```

CAUTION!
Values between curly braces {} are specific and volatile!
Command option flags between square hooks [] are optional.
Be sure to always have the right value in your specific case!

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
execute isolatest, indicate target device

```
% sh isolatest /dev/sd{AI}
```

## 04
insert usb2

Prepare ext4 partitions labeled REPO, CODE and KEYS

CAUTION! DESIGNATE THE RIGHT DEVICE!

WARNING! ALL DATA WILL BE DESTROYED!

NOTICE for offline installation only REPO and CODE are mandatory

```
% sudo gdisk /dev/sd{RC}
```

enter:
	    o	to rewrite GPT table
		n	create a 10G 8300 partition (REPO)
		n	create a 10G 8300 partition (CODE)
		n	create a  1G 8300 partition (KEYS)
		w	write changes to device
		q	quit gdisk

NOTICE approximated partition sizes

```
% sudo mkfs.ext4 -L REPO /dev/sd{RC2}
% sudo mkfs.ext4 -L CODE /dev/sd{RC3}
% sudo mkfs.ext4 -L KEYS /dev/sd{RC4}
% mkdir -p $HOME/dock/{2,3/code,4}
```

## 05
write the REPO, CODE and KEYS partitions

```
% make-recov [repo] [code] [keys]
```

Preparation is now finished. We now have:

usb1	with archiso

usb2	with REPO, CODE and KEYS

usb3	optional boot device


# installation
--------------------------------

The installation phase is executed on the target machine.

## 11
WARNING! ALL DATA ON TARGET MACHINE WILL BE DESTROYED!

switch the target machine off

insert usb1

switch the target machine on

## 12
after entering the commandline prompt

insert usb2

```
% mkdir tmp
```

then, get device information

```
% lsblk
```

or, for more information

```
% lsblk -paf
```

or

```
% blkid
```

mount CODE to tmp

CAUTION! DESIGNATE THE RIGHT DEVICE!

```
% mount /dev/sdX tmp
```

execute 0init.sh to start the installation

```
% sh tmp/code/hajime/0init.sh [--offline]|[--online]|[--hybrid] [--config machine.conf]
```

If you have configured an installation configuration for your specific machine,

you can run hajime unattended. be 100% sure to have the right settings!

If you have an offline repository, hajime can be run entirely offline.

It is recommended to install entirely offline and connect to any network

not earlier than after the installation is fully completed.

Read the text carefully, acknowledge, then confirm.

## 13	start hajime
insert usb3 (optional)

let's roll!

```
% sh hajime/1base.sh [--offline]|[--online]|[--hybrid] [--config machine.conf]
```

from here run the scripts in their numerical order:
	1base.sh
	2conf.sh
	3post.sh
	4apps.sh
	5dtcf.sh

CAUTION! READ AND EXECUTE THE ON-SCREEN INSTRUCTIONS THOROUGHLY!

or

If you have configured a config file; enjoy your free time during the unattended installation!

the system reboots after 2conf.sh has been executed


## install log
--------------------------------
For debug purposes it can be useful to be able to review an logging of the installation process.
Create a full debug log of the installation with:

```
sh hajime/1base.sh 2>&1 | tee tmp/1base.log
```

NOTICE commandline feedback can be influenced by tee


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
