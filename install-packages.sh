#! /usr/bin/env sh


base_packages ()
{
    # packages 1base

    base_pkgs=(

	## core
	base linux linux-firmware

	## base-devel
	base-devel

    )
}


conf_packages ()
{
    # packages 2conf

    conf_pkgs=(

	## linux kernel
	#linux (in base_pkgs)
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
	emacs neovim

	## install_helpers
	git reflector

	## network
	dhcpcd
	#systemd-networkd systemd-resolved

	## wireless network
	wpa_supplicant wireless_tools iw

	## secure_connections
	openssh

	## system_security
	#nss-certs; comes with nss in core

    )
}


post_packages ()
{
    # packages 3post

    post_pkgs=(

	## post_core_additions
	archlinux-keyring lsof mlocate neofetch neovim pacman-contrib

    )
}


apps_packages ()
{
    # packages 4apps

    apps_pkgs=(


	## core_applications ()


	## wayland
	dotool qt6-wayland tofi wl-clipboard wev wlroots xorg-xwayland
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
	bat eza fzf fzf-tab-git mako pv
	#bat eza delta fzf fzf-tab-git getoptions mako pv
	#wofi rofi bemenu-wayland

	## manpages
	man-db man-pages tldr

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
	#otf-unifonts ttf-unifonts terminus-font ttf-inconsolata

	## display
	brightnessctl

	## input_devices
	#zsa-wally-cli wvkbd

	## audio
	alsa-utils pipewire pipewire-alsa pipewire-jack pipewire-pulse sof-firmware
	#pulseaudio pulseaudio-alsa pulsemixer qpwgraph-qt5

	## image_viewers
	sxiv feh imv
	#fim ueberzug geekie

	## bluetooth
	bluez bluez-utils pulseaudio-bluetooth


	## additional_tools ()


	## archivers
	#vimball

	## build_tools
	make yay

	## terminal_text_tools
	emacs figlet qrencode zbar jq tinyxxd

	## terminal_file_manager
	lf
	#yazi (=aur)
	#vifm lf-git nnn ranger

	## file_tools
	rsync simple-mtpfs fd dust
	#gdisk tmsu trash-cli

	## debugging
	strace
	#gdb valgrind

	## network tools
	mtr iftop whois ufw trippy
	#bind-tools wireshark-cli wireshark-qt

	## programming languages
	go zig zls
	#lisp perl rustup zig go lua python

	## python additions
	#python-pip

	## android tools
	#android-tools adb-rootless-git

	## internet_browser
	firefox-developer-edition qutebrowser nyxt w3m
	#icecat lynx

	## internet_search
	#googler ddgr surfraw

	## internet_tool
	urlscan

	## feeds
	newsboat

	## email
	neomutt msmtp isync notmuch protonmail-bridge

	## time_management
	#calcurse task

	## arithmatic
	bc qalculate-qt

	## mathematics
	#gnu-plot

	## accounting
	#ledger hledger

	## download_utilities
	aria2 transmission-cli
	#transmission-remote-cli-git

	## system_info
	lshw usbutils

	## system_monitoring
	btop glances viddy
	#ccze htop

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
	wf-recorder obs xdg-desktop-portal-wlr qt6ct wlrobs

	## video_editing
	kdenlive breeze

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
	sqlitebrowser arch-wiki-docs arch-wiki-lite


	## aur applications ()


	## create the list for aur_applications:
	#for dir in $(fd . --max-depth 1 --type directory ~/.cache/yay | sed 's/\/$//'); do printf '%s \\\n' "$(basename "$dir")"; done | wl-copy
	## or
	#yay -Qqm

	7-zip
	# 7-zip-debug
	base16-shell-preview
	brave-bin
	# calcmysky
	# calcmysky-debug
	# cava
	# cava-debug
	dotool
	dotool-debug
	fzf-tab-git
	imhex
	# kmonad-bin
	# kmonad-bin-debug
	lisp
	# mbrola
	# ncurses5-compat-libs
	# ncurses5-compat-libs-debug
	# obs-backgroundremoval
	# obs-backgroundremoval-debug
	# otf-unifont
	# protonmail-bridge-debug
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
	# qt5-webkit-debug
	# qxlsx-qt6
	# sdl2
	# sentry-native-debug
	# showmethekey
	# showmethekey-debug
	simple-mtpfs
	# simple-mtpfs-debug
	ssss
	# stellarium
	# stellarium-debug
	swaynagmode
	tofi
	# tofi-debug
	# viddy
	wlrobs
	# wlrobs-debug
	yay
	# yay-debug
	yazi-git
	# yazi-git-debug

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
