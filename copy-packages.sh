#! /usr/bin/env sh

###
###   ___ ___        _ __   __ _
###  / __/ _ \ _____| '_ \ / _` |
### | (_| (_) |_____| |_) | (_| |
###  \___\___/      | .__/ \__,_|
###                 |_|
###
###  # # # # # #
###       #
###  # # # # # #
###

: '
copy-packages
for offline installation
copyright (c) 2019 - 2025  |  oxo

GNU GPLv3 GENERAL PUBLIC LICENSE
This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
https://www.gnu.org/licenses/gpl-3.0.txt

@oxo@qoto.org


# description

# dependencies
  archlinux installation
  REPO

# usage
  copy-packages $dst

# example
  n/a

# '


#set -o errexit
#set -o nounset
set -o pipefail

# initial definitions

## script
script_name='copy-packages.sh'
developer='oxo'
license='gplv3'
initial_release='2019'

## hardcoded variables
db_name='offline'
cy="$XDG_CACHE_HOME/yay"
vcpp='/var/cache/pacman/pkg'
pkgs_to_repo="$XDG_CACHE_HOME/temp/pkgs-to-repo-$(id -u $USER)"
pkgs_to_copy="$XDG_CACHE_HOME/temp/pkgs-to-copy-$(id -u $USER)"
pkgs_hajime="$HOME/c/git/code/hajime/pkgs-hajime-$(id -u $USER)"
pkgs_to_copy_err="$XDG_CACHE_HOME/temp/pkgs-to-copy-$(id -u $USER)-err"

#--------------------------------


get_args()
{
    args="$@"
    dst="$args"
    # TODO DEV TEMPO one arg; package cache file destination
}


define_base_packages ()
{
    ## packages from 1base
    pkg_help='reflector'
    pkg_core='base linux linux-firmware'
    pkg_base_devel='base-devel'
}


define_conf_packages ()
{
    ## packages from 2conf
    linux_kernel="linux-headers"	#linux 1base
    linux_lts_kernel="linux-lts linux-lts-headers"
    # [Install Arch Linux on LVM - ArchWiki]
    # (https://wiki.archlinux.org/title/Install_Arch_Linux_on_LVM#Adding_mkinitcpio_hooks)
    # lvm2 is needed for lvm2 mkinitcpio hook
    ## [Fix missing libtinfo.so.5 library in Arch Linux]
    ## (https://jamezrin.name/fix-missing-libtinfo.so.5-library-in-arch-linux)
    ## prevent error that library libtinfo.so.5 couldn’t be found
    core_applications='lvm2'
    text_editor="emacs neovim"
    install_helpers="reflector base-devel git"	#binutils 3post base-devel group
    network='dhcpcd'
    #network='dhcpcd systemd-networkd systemd-resolved'
    network_wl="wpa_supplicant wireless_tools iw"
    secure_connections="openssh"
    system_security='' #nss-certs; comes with nss in core
}


define_post_packages ()
{
    ## packages from 3post
    post_core_additions='archlinux-keyring lsof mlocate neofetch neovim pacman-contrib wl-clipboard'
}


define_core_applications()
{
    ## packages from 4apps-core_applications
    wayland='dotool qt6-wayland wev wlroots xorg-xwayland'
    #wayland='dotool qt5-wayland qt6-wayland wev wlroots xorg-xwayland'
    ## qt5-wayland to prevent:
    ## WARNING: Could not find the Qt platform plugin 'wayland' in
    ## i.e. when starting qutebrowser
    ## dotool for speech-to-text and yank-buffer

    dwm='i3blocks sway swaybg swayidle swaylock swaynagmode'
    #'waybar'

    shell='zsh bash-language-server'

    shell_additions='zsh-completions zsh-syntax-highlighting'

    terminal='alacritty foot tmux'
    #'zellij byobu termite-nocsd urxvt'

    terminal_additions='bat eza fzf fzf-tab-git mako pv'
    #terminal_additions='bat eza delta fzf fzf-tab-git getoptions mako pv'
    #'wofi rofi bemenu-wayland'

    manpages='man-db man-pages tldr'

    password_security='pass pass-otp yubikey-manager'
    #'pass-tomb bitwarden-cli pass-wl-clipboard'

    encryption='gnupg sha3sum'
    #encryption='gnupg ssss sha3sum'
    #'haveged veracrypt tomb'

    security='opendoas arch-audit'

    secure_connections='wireguard-tools sshfs'
    #secure_connections='wireguard-tools protonvpn-cli-ng sshfs'

    filesystems='dosfstools ntfs-3g'

    fonts=''
    #fonts='otf-unifonts'
    #'ttf-unifonts terminus-font ttf-inconsolata'

    display='brightnessctl'

    input_devices=''
    #input_devices='zsa-wally-cli wvkbd'

    audio='alsa-utils pipewire pipewire-alsa pipewire-jack pipewire-pulse qpwgraph-qt5 sof-firmware'
    #'pulseaudio pulseaudio-alsa pulsemixer'

    image_viewers='sxiv feh imv'
    #'fim ueberzug geekie'

    bluetooth='bluez bluez-utils pulseaudio-bluetooth'
}


define_additional_tools()
{
    ## packages from 4apps-additional_tools
    archivers=''
    #'vimball'

    build_tools='make yay'

    terminal_text_tools='emacs figlet qrencode zbar jq tinyxxd'

    terminal_file_manager='lf'
    #'vifm lf-git nnn'

    file_tools='rsync simple-mtpfs fd dust'
    #file_tools='rsync gdisk simple-mtpfs fd dust'
    #'tmsu trash-cli'

    debugging='strace'
    #'gdb valgrind'

    network_tools='mtr iftop whois ufw trippy'
    #network_tools='mtr iftop bind-tools whois ufw trippy'
    #'wireshark-cli wireshark-qt'

    prog_langs='zig zls'
    #'lisp perl rustup zig go lua python'

    python_additions=''
    #'python-pip'

    android_tools=''
    #'android-tools adb-rootless-git'

    internet_browser='firefox-developer-edition qutebrowser nyxt w3m'
    #'icecat lynx'

    internet_search=''
    #'googler ddgr surfraw'

    internet_tool='urlscan'

    feeds='newsboat'

    email='neomutt msmtp isync notmuch protonmail-bridge'

    time_management=''
    #'calcurse task'

    arithmatic='bc qalculate-qt'

    mathematics=''
    #'gnu-plot'

    accounting=''
    #'ledger hledger'

    download_utilities='aria2 transmission-cli'
    #download_utilities='aria2 transmission-cli transmission-remote-cli-git'

    system_info='lshw usbutils'

    system_monitoring='btop glances'
    #system_monitoring='btop glances viddy'
    #'ccze htop'

    virtualization=''
    #'qemu-full virt-manager virt-viewer bridge-utils dnsmasq libquestfs'
    #'virtualbox virtualbox-ext-oracle'

    #[7-kvm.sh · main · Stephan Raabe / archinstall · GitLab](https://gitlab.com/stephan-raabe/archinstall/-/blob/main/7-kvm.sh)
    #virt-manager virt-viewer qemu vde2 ebtables iptables-nft nftables dnsmasq bridge-utils ovmf swtpm

    image_capturing='grim slurp'

    image_editors='imagemagick'

    pdf_viewers='mupdf zathura-pdf-mupdf'
    #'calibre okular'

    video_capturing='wf-recorder obs xdg-desktop-portal-wlr qt6ct wlrobs'

    video_editing='kdenlive breeze'

    video_tools='yt-dlp mpv'
    #video_tools='yt-dlp mpv pipe-viewer'
    #'straw-viewer youtube-viewer youtube-dl'

    photo_editing=''
    #'gimp'

    photo_management=''
    #'digikam darktable'

    vector_graphics_editing=''
    #'inkscape'

    office_tools=''
    #office_tools='presenterm'
    #'libreoffice-fresh mdp'

    cad=''
    #'freecad'

    navigation='gpsbabel viking'
    #'qgis grass stellarium'

    weather=''
    #'wttr'

    database='sqlitebrowser arch-wiki-docs arch-wiki-lite'
}


define_manual_added ()
{
    ## manually added packages (here)
    linux_kernel='linux linux-headers'
}


create_base_packages_list ()
{
    ## packages from 1base
    base_packages=(\
		   $pkg_help \
		       $pkg_core \
		       $pkg_base_devel\
	)
}


create_conf_packages_list ()
{
    ## packages from 2conf
    conf_packages=(\
		   $linux_kernel \
		       $linux_lts_kernel \
		       $core_applications \
		       $text_editor \
		       $install_helpers \
		       $network \
		       $network_wl \
		       $secure_connections\
	)
}


create_post_packages_list ()
{
    ## packages from 3post
    post_packages=(\
		   $post_core_additions\
	)
}


create_core_applications_list ()
{
    ## packages from 4apps-core_applications
    core_applications=(\
		       $wayland \
			   $dwm \
			   $shell \
			   $shell_additions \
			   $terminal \
			   $terminal_additions \
			   $manpages \
			   $password_security \
			   $encryption \
			   $security \
			   $secure_connections \
			   $filesystems \
			   $fonts \
			   $display \
			   $input_devices \
			   $audio \
			   $image_viewers \
			   $bluetooth\
	)
}


create_additional_tools_list ()
{
    ## packages from 4apps-additional_tools
    additional_tools=(\
		      $build_tools \
			  $archivers \
			  $terminal_text_tools \
			  $terminal_file_manager \
			  $file_tools \
			  $database\
			  $debugging \
			  $network_tools \
			  $prog_langs \
			  $python_additions \
			  $android_tools \
			  $internet_browser \
			  $internet_search \
			  $internet_tool \
			  $feeds \
			  $email \
			  $time_management \
			  $arithmatic \
			  $mathematics \
			  $accounting \
			  $download_utilities \
			  $system_info \
			  $system_monitoring \
			  $virtualization \
			  $image_capturing \
			  $image_editors \
			  $pdf_viewers \
			  $video_capturing \
			  $video_editing \
			  $video_tools \
			  $photo_editing \
			  $photo_management \
			  $vector_graphics_editing \
			  $office_tools \
			  $cad \
			  $navigation \
			  $weather\
	)
}


create_aur_applications_list ()
{
    ## create the list for aur_applications:
    #for dir in $(fd . --max-depth 1 --type directory ~/.cache/yay | sed 's/\/$//'); do printf '%s \\\n' "$(basename "$dir")"; done | wl-copy
    aur_applications=(\
		      brave-bin \
			  #calcmysky \
			  #cava \
			  dotool \
			  fzf-tab-git \
			  #lisp \
			  #mbrola \
			  #md2pdf-git \
			  ncurses5-compat-libs \
			  #nerd-dictation-git \
			  obs-backgroundremoval \
			  otf-unifont \
			  #presenterm-bin \
			  #qpwgraph-qt5 \
			  #qt5-webkit \
			  simple-mtpfs \
			  #ssss \
			  stellarium \
			  swaynagmode \
			  #ttf-unifont \
			  #viddy \
			  #virtualbox-ext-oracle \
			  #vosk-api \
			  wev \
			  wlrobs \
			  #wttr \
			  yay\
	)
}


create_manual_added_list ()
{
    ## packages from manual_added
    manual_packages=(\
		   $linux_kernel \
	)
}


create_hajime_pkgs ()
{
    define_base_packages
    create_base_packages_list
    apps_pkgs+=("${base_packages[@]}")

    define_conf_packages
    create_conf_packages_list
    apps_pkgs+=("${conf_packages[@]}")

    define_post_packages
    create_post_packages_list
    apps_pkgs+=("${post_packages[@]}")

    define_core_applications
    create_core_applications_list
    apps_pkgs+=("${core_applications[@]}")

    define_additional_tools
    create_additional_tools_list
    apps_pkgs+=("${additional_tools[@]}")

    create_aur_applications_list
    apps_pkgs+=("${aur_applications[@]}")

    define_manual_added
    create_manual_added_list
    apps_pkgs+=("${manual_packages[@]}")

    ## write pkgs_hajime (pkgs-hajime-1000)
    printf '%s\n' "${apps_pkgs[@]}" | sort > "$pkgs_hajime"
}


define_pkgs_cache_ls ()
{
    # define the packages that have to be copied to the repo

    ## cache source file pkgs-cache-ls
    pkgs_cache_ls="$XDG_CACHE_HOME/temp/pkgs-cache-ls-$(id -u $USER)"

    ## remove existing pkgs_cache_ls file
    [[ -f $pkgs_cache_ls ]] && rm -rf $pkgs_cache_ls

    ## vcpp
    add_pkg_cache_ls "$vcpp" pacman

    ## cy
    add_pkg_cache_ls "$cy" yay
}


create_pkgs_to_copy ()
{
    ## remove existing pkgs_hajime_err file
    [[ -f $pkgs_to_copy ]] && rm -rf $pkgs_to_copy
    [[ -f $pkgs_to_copy_err ]] && rm -rf $pkgs_to_copy_err

    ## get latest package cache file for every pkg_hajime in pkgs_cache_ls
    while read -r pkg_hajime; do

	get_latest_package

	if [[ -z "$pkg_ver_latest" ]]; then

	    ## error message on empty pkg_ver_latest
	    pkg_ver_latest='empty pkg_ver_latest'
	    printf 'ERROR adding %s %s\n' "$pkg_hajime" "$pkg_ver_latest" >> $pkgs_to_copy_err
	    printf 'ERROR adding %s %s\n' "$pkg_hajime" "$pkg_ver_latest"

	elif [[ -n "$pkg_ver_latest" ]]; then

	    printf '%s\n' "$pkg_ver_latest" >> $pkgs_to_copy
	    printf 'added main %s %s\n' "$pkg_hajime" "$pkg_ver_latest"

	    pkg_get_deps $pkg_hajime
	    get_dep_file

	fi

    done < "$pkgs_hajime"
}


add_pkg_cache_ls ()
{
    pkg_cache_dir="$1"
    cache_source="$2"

    case $cache_source in

	pacman )
	    for file in $pkg_cache_dir/*; do

		realpath $file >> $pkgs_cache_ls

		printf 'building pkgs_cache_ls %s\n' "$(basename $file)"

	    done
	    ;;

	yay )
	    realpath $(fd --type file '.*(\.pkg)?\.tar\.(gz|xz|zst)$' $pkg_cache_dir) >> $pkgs_cache_ls

	    printf 'building pkgs_cache_ls %s\n' "$(basename $file)"
	    ;;

    esac

    ## version sort and uniq pkgs_cache_ls content
    pkgs_cache_ls_sorted=$(sort --version-sort $pkgs_cache_ls | uniq)
    printf '%s' "$pkgs_cache_ls_sorted" > $pkgs_cache_ls
}


get_latest_package ()
{
    # pkg_name_ver=$(pacman -Qo $pkg_hajime | cut -d ' ' -f 5-6 | tr ' ' '-')
    pkg_ver_latest=$(cat "$pkgs_cache_ls" \
		       | grep --extended-regexp ".*/${pkg_hajime}-[0-9].*\.pkg\.tar\.(xz|zst)$" \
		       | sort --version-sort \
		       | tail -n 1)
}


get_latest_dep ()
{
    # pkg_name_ver=$(pacman -Qo $pkg_hajime | cut -d ' ' -f 5-6 | tr ' ' '-')
    pkg_dep_latest=$(cat "$pkgs_cache_ls" \
			 | grep --extended-regexp ".*/${pkg_dep}-[0-9].*\.pkg\.tar\.(xz|zst)$" \
			 | sort --version-sort \
			 | tail -n 1)
}


pkg_get_deps ()
{
    pkg_main=$1

    ## tail first line of pactree is queried package
    pkg_main_deps=$(pactree --linear --depth 1 $pkg_main | tail -n +2 | sort)
}


get_dep_file ()
{
    for pkg_dep in $pkg_main_deps; do

	get_latest_dep

	printf '%s\n' "$pkg_dep_latest" >> $pkgs_to_copy
	printf 'added dep  %s %s\n' "$pkg_dep" "$pkg_dep_latest"

    done
}


optimize_pkgs_to_repo ()
{
    ## sed removes empty lines, sort and uniq
    pkgs_2_repo=$(sed '/^\s*$/d' $pkgs_to_copy | sort | uniq)
    printf '%s' "$pkgs_2_repo" > $pkgs_to_repo
}


copy_pkgs_to_repo ()
{
    mountpoint -q "$dst"

    if [[ $? -eq 0 ]]; then

	for package in $(cat $pkgs_to_repo); do

	    if [[ -f $package ]]; then

		## copy pkg
		printf 'copy pkg to %s %s\n' "$dst" "$package"
		cp "$package" "$dst"

		## copy sig
		if [[ -f "$package".sig ]]; then

		    printf 'copy sig to %s %s\n' "$dst" "$package"
		    cp "$package".sig "$dst"

		fi

	    fi

	done

    fi
}


build_database ()
{
    mountpoint -q "$dst"

    if [[ $? -eq 0 ]]; then

	# build custom pacman offline package database
	echo

	for package in $(cat $pkgs_to_repo); do
	    #TODO DEV read file directly

	    p_basename=$(basename $package)
	    printf '==> adding %s/%s\n' "$dst" "$p_basename"

	    repo-add --new --remove --include-sigs $dst/$db_name.db.tar.zst $dst/$p_basename

	done

    fi
}


main ()
{
    get_args "$@"
    create_hajime_pkgs
    define_pkgs_cache_ls
    create_pkgs_to_copy
    optimize_pkgs_to_repo
    copy_pkgs_to_repo
    build_database
}

main "$@"
