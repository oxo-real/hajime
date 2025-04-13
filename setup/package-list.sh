#! /usr/bin/env sh


# metapackage dependencies

## base (3-2)
: '
    ## very very base
    filesystem gcc-libs glibc bash

    ## POSIX tools
    coreutils file findutils gawk grep procps-ng sed tar

    ## standard linux toolset
    gettext pciutils psmisc shadow util-linux bzip2 gzip xz

    ## distro defined requirements
    licenses pacman archlinux-keyring systemd systemd-sysvcompat

    ## networking, ping, etc
    iputils iproute2
# '

## base-devel (1-2)
: '
    archlinux-keyring
    autoconf
    automake
    binutils
    bison
    debugedit
    fakeroot
    file
    findutils
    flex
    gawk
    gcc
    gettext
    grep
    groff
    gzip
    libtool
    m4
    make
    pacman
    patch
    pkgconf
    sed
    sudo
    texinfo
    which
# '


base_packages ()
{
    # packages 1base

    base_pkgs=(
	## installed with pacstrap (1base install_packages)

	## core (essential packages)
	base linux linux-firmware

	## base-devel
	base-devel
    )
}


conf_packages ()
{
    # packages 2conf

    conf_pkgs=(
	## installed from chroot jail (/mnt) with pacman (2conf install_core)

	## linux kernel
	linux-headers

	## linux lts kernel
	linux-lts linux-lts-headers

	## intel micro code
	intel-ucode iucode-tool

	## core_applications
	## lvm2 is needed for lvm2 mkinitcpio hook
	## [Install Arch Linux on LVM - ArchWiki]
	## (https://wiki.archlinux.org/title/Install_Arch_Linux_on_LVM#Adding_mkinitcpio_hooks)
	## [Fix missing libtinfo.so.5 library in Arch Linux]
	## (https://jamezrin.name/fix-missing-libtinfo.so.5-library-in-arch-linux)
	## prevent error that library libtinfo.so.5 couldn’t be found
	lvm2

	## text editors
	emacs-wayland neovim

	## install helper
	git rsync

	## network
	dhcpcd reflector
	#systemd-networkd systemd-resolved

	## wireless network
	wpa_supplicant wireless_tools iw

	## secure_connections
	openssh
    )
}


post_packages ()
{
    # packages 3post

    post_pkgs=(

	## post_core_additions
	lsof mlocate neofetch pacman-contrib
    )
}


apps_packages ()
{
    # packages 4apps

    apps_pkgs=(


	## core_applications ()


	## wayland
	dotool tofi wl-clipboard wev qt6-wayland
	# wlroots xorg-xwayland
	## qt5-wayland to prevent:
	## WARNING: Could not find the Qt platform plugin 'wayland' in
	## i.e. when starting qutebrowser
	## dotool for speech-to-text and yank-buffer
	#qt5-wayland

	## dwm
	i3blocks sway swaybg swayidle swaylock swaynagmode
	#waybar

	## shell
	zsh bash-language-server

	## shell_additions
	zsh-completions zsh-syntax-highlighting

	## terminal
	alacritty foot tmux
	#zellij byobu termite-nocsd urxvt

	## terminal_additions
	bat fzf fzf-tab-git mako pv
	#bat eza delta fzf fzf-tab-git getoptions mako pv
	#wofi rofi bemenu-wayland

	## manpages
	man-db man-pages tldr

	## network
	networkmanager

	## password_security
	pass pass-otp yubikey-manager
	#pass-tomb bitwarden-cli pass-wl-clipboard

	## encryption
	gnupg sha3sum
	#encryption='gnupg ssss sha3sum'
	#'haveged veracrypt tomb'

	## security
	opendoas arch-audit

	## secure_connections
	wireguard-tools sshfs
	#wireguard-tools protonvpn-cli-ng sshfs

	## filesystems
	dosfstools ntfs-3g

	## fonts
	adobe-source-code-pro-fonts ttf-0xproto-nerd
	#otf-unifonts ttf-unifonts terminus-font ttf-inconsolata

	## display
	brightnessctl

	## input_devices
	#zsa-wally-cli wvkbd

	## cursor shapes
	#xorg-xcursorgen

	## multimedia
	## pipewire audio server
	pipewire pipewire-alsa
	## session manager
	wireplumber
	## pulseaudio compatibility
	pipewire-pulse
	# alsa-utils sof-firmware pipewire-jack
	#pulseaudio pulseaudio-alsa pulsemixer qpwgraph-qt5

	## image_viewers
	sxiv feh imv
	#fim ueberzug geekie

	## bluetooth
	bluez bluez-utils
	#pulseaudio-bluetooth


	## additional_tools ()


	## archivers
	#vimball

	## terminal_text_tools
	emacs figlet qrencode zbar jq tinyxxd

	## terminal_file_manager
	fff lf
	#yazi (=aur)
	#vifm lf-git nnn ranger

	## file_tools
	dust fd ripgrep simple-mtpfs
	#gdisk tmsu trash-cli

	## debugging
	# strace
	#gdb valgrind

	## network tools
	#mtr iftop whois ufw trippy
	#bind-tools wireshark-cli wireshark-qt

	## programming languages
	# go zig zls
	#lisp perl rustup zig go lua python

	## python additions
	#python-pip

	## android tools
	#android-tools adb-rootless-git

	## internet_browser
	firefox-developer-edition qutebrowser w3m
	#icecat lynx
	#nyxt  ## seems to inflict a pacman error: libicuuc.so.75

	## internet_search
	#googler ddgr surfraw

	## internet_tool
	urlscan

	## feeds
	newsboat

	## email
	#neomutt msmtp isync notmuch protonmail-bridge

	## time_management
	#calcurse task

	## arithmatic
	bc qalculate-qt

	## mathematics
	#gnu-plot

	## accounting
#	#ledger hledger

	## download_utilities
	transmission-cli
	#aria2 transmission-remote-cli-git

	## system_info
	lshw usbutils

	## system_monitoring
	#glances
	#viddy btop ccze htop

	## virtualization
	#qemu-full virt-manager virt-viewer bridge-utils dnsmasq libquestfs
	#virtualbox virtualbox-ext-oracle
	#[7-kvm.sh · main · Stephan Raabe / archinstall · GitLab](https://gitlab.com/stephan-raabe/archinstall/-/blob/main/7-kvm.sh)
	#virt-manager virt-viewer qemu vde2 ebtables iptables-nft nftables dnsmasq bridge-utils ovmf swtpm

	## image_capturing
	grim slurp

	## image_editors
	imagemagick

	## pdf_viewers
	mupdf zathura-pdf-mupdf
	#calibre okular

	## video_capturing
	# wf-recorder xdg-desktop-portal-wlr qt6ct wlrobs
	#obs

	## video_editing
	# kdenlive breeze

	## video_tools
	yt-dlp mpv
	#video_tools=yt-dlp mpv pipe-viewer
	#straw-viewer youtube-viewer youtube-dl

	## photo_editing
	#gimp

	## photo_management
	#digikam darktable

	## vector_graphics_editing
	#inkscape

	## office_tools
	#presenterm libreoffice-fresh mdp

	## cad
	#freecad

	## navigation
	gpsbabel viking
	#qgis grass stellarium

	## weather
	#wttr

	## database
	arch-wiki-docs arch-wiki-lite
	#sqlitebrowser

    # foreign packages from arch user repository

 	## create foreign package list:
	#for dir in $(fd . --max-depth 1 --type directory ~/.cache/yay | sed 's/\/$//'); do printf '%s \\\n' "$(basename "$dir")"; done | wl-copy
	## or
	#yay -Qqm
	#yay -Qm (version included)

	#7-zip
	base16-shell-preview
	# brave-bin
	# calcmysky
	# cava
	# dotool
	# fzf-tab-git
	# imhex
	# kmonad-bin
	# lisp
	# mbrola
	# ncurses5-compat-libs
	# obs-backgroundremoval
	# otf-unifont
	protonvpn-cli
	# pup
	# python-future
	# python-jplephem
	# python-mock
	# python-proton-client
	# python-protonvpn-nm-lib
	# python-pythondialog
	# python-sgp4
	# python-skyfield
	# qxlsx-qt6
	# sdl2
	# showmethekey
	# simple-mtpfs
	ssss
	# stellarium
	# swaynagmode
	# tofi
	# viddy
	#wlrobs
	#yay-bin
	# yazi-git
    )
}


main ()
{
    base_packages
    conf_packages
    post_packages
    apps_packages
}

main
