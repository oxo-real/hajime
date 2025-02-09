#! /usr/bin/env sh

###  _            _ _
### | |__   __ _ (_|_)_ __ ___   ___    __ _ _ __  _ __  ___
### | '_ \ / _` || | | '_ ` _ \ / _ \  / _` | '_ \| '_ \/ __|
### | | | | (_| || | | | | | | |  __/ | (_| | |_) | |_) \__ \
### |_| |_|\__,_|/ |_|_| |_| |_|\___|  \__,_| .__/| .__/|___/4
###            |__/                         |_|   |_|
###
###  # # # # # #
###       #
###  # # # # # #
###

: '
hajime_4apps
fourth part of linux installation
copyright (c) 2019 - 2024  |  oxo

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
  fourth part of a series
  arch linux installation: apps

# dependencies
  archlinux installation
  archiso, REPO, 0init.sh, 1base.sh, 2conf.sh, 3post.sh

# usage
  sh hajime/4apps.sh

# example
  n/a

# '


#set -o errexit
set -o nounset
set -o pipefail

# initial definitions

## script
script_name='4apps.sh'
developer='oxo'
license='gplv3'
initial_release='2019'

## hardcoded variables
# user customizable variables

## offline installation
offline=1
code_dir="/home/$(id -un)/dock/3"
repo_dir="/home/$(id -un)/dock/2"
repo_re="\/home\/$(id -un)\/dock\/2"
file_etc_pacman_conf='/etc/pacman.conf'
aur_dir="$repo_dir/aur"

#--------------------------------

define_core_applications()
{
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


create_core_applications_list()
{
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


create_additional_tools_list()
{
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


create_aur_applications_list()
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
			  yay \
	)
}


create_package_list ()
{
    define_core_applications
    create_core_applications_list

    define_additional_tools
    create_additional_tools_list

    create_aur_applications_list

    full_package_list+=("${core_applications[@]}" "${additional_tools[@]}" "${aur_applications[@]}")

    ts=$(printf '%s_%X\n' "$(date $DT)" "$(date +'%s')")
    ## core package list
    ### packages mentioned in hajime_4apps
    cpl="$HOME/c/git/code/hajime/${ts}-packages"
    printf '%s\n' "${full_package_list[@]}" > "$cpl"
}


get_args()
{
    args=$@
    ## TODO DEV TEMPO one arg; destination
    dst=$args
}


copy_packages ()
{
    ## pacman_q package space installed_version
    pacman_q=$(pacman -Q | sort --version-sort)
    core_pkg_list="$XDG_DATA_HOME/c/git/code/hajime/20250208_134925_67A752D5-packages"

    vcpp='/var/cache/pacman/pkg'
    cy="$XDG_CACHE_HOME/yay"

    ## define vcpp_pkg_files
    for file in "$vcpp/*"; do

	vcpp_pkg_files+=$file

    done

    ## define cy_pkg_files
    for file in "$cy/*"; do

	cy_pkg_files+=$file

    done

    ## get latest package
    while read -r pkg_2_copy; do

	ver_2_copy=$(grep --extended-regexp "^${pkg_2_copy}\s" <<< $pacman_q | awk '{print $2}')

	case $(wc -l <<< $ver_2_copy) in

	    1 )
		:
		;;

	    * )
		## more than one version
		exit 12
		;;

	esac

	## vcpp_pkg
	printf -v vcpp_p '%s-%s' "$pkg_2_copy" "$ver_2_copy"

	pkg_applicants=()
	for file in "$vcpp"/"$pkg_2_copy"-"$ver_2_copy"*; do

	    ## populate applicants whose file starts with vcpp/pkg_2_copy-ver_2_copy*
	    pkg_applicants+=$(printf '%s\n' "$file")

	done

	if [[ "${#pkg_applicants[@]}" -eq 1 ]]; then

	    vcpp_pkg="${pkg_applicants[0]}"

	elif [[ "${#pkg_applicants[@]}" -gt 1 ]]; then

	    pkg_applicants=()
	    for applicant in "${pkg_applicants[@]}"; do

		## rewrite pkg_applicants
		pkg_applicants+=$(printf '%s\n' "$file")

	    done

printf "DEV$LINENO %s\n" "${pkg_applicants[@]}"
exit 255

	fi

	## at this point we have the 'file' in the form of vcpp/pkg_2_copy-ver_2_copy

 	if [[ -f $vcpp_pkg ]]; then

	    package=$vcpp_pkg

	elif [[ ! -f $vcpp_pkg ]]; then

	    ## cy_pkg
	    for file in ${cy}/${pkg_2_copy}*; do

		cy_pkg=$(printf '%s' $file | grep -v sig | sort --version-sort | tail -n 1)

	    done
	    # cy_pkg=$(ls ${cy}/${pkg_2_copy}/${pkg_2_copy}* | grep -v sig | grep -v debug | sort --version-sort | tail -n 1)

	    package=$cy_pkg

	    if [[ -f package ]]; then

		## remove vcpp ls error
		tput cuu1
		printf "\r"; tput el

	    fi

	fi

	if [[ ! -f $package ]]; then

	    printf '%s not found in cache (vcpp & cy)\n' $pkg_2_copy

	elif [[ -f $package ]]; then

	    ## copy package
	    cp $package $dst


	    # check for dependencies

	    ## define dependencies
	    pkg_deps=$(pactree --linear $core_pkg_list | sort -u)

	    ## loop through package dependencies
	    while read -r dep_2_copy; do

		for file in ${vcpp}/${dep_2_copy}*; do

		    vcpp_pkg=$(printf '%s' $file | grep -v sig | sort --version-sort | tail -n 1)

		done
		#vcpp_dep=$(ls ${vcpp}/${dep_2_copy}* | grep -v sig | grep -v debug | sort --version-sort | tail -n 1)

		if [[ -f $vcpp_dep ]]; then

		    package=$vcpp_dep

		elif [[ ! -f $vcpp_dep ]]; then

		    ## cy_dep
		    for file in ${cy}/${dep_2_copy}*; do

			cy_dep=$(printf '%s' $file | grep -v sig | sort --version-sort | tail -n 1)

		    done
		    #cy_dep=$(ls ${cy}/${dep_2_copy}/${dep_2_copy}* | grep -v sig | grep -v debug | sort --version-sort | tail -n 1)

		    package=$cy_dep

		    if [[ -f package ]]; then

			## remove vcpp ls error
			tput cuu1
			printf "\r"; tput el

		    fi

		fi

		if [[ ! -f $package ]]; then

		    printf '%s not found in cache (vcpp & cy)\n' $dep_2_copy

		elif [[ -f $package ]]; then

		    ## check if dep already exists in repo
		    if [[ ! -f $dst/$(basename $package) ]]; then

			## copy package dependency
			cp $package $dst

		    fi

		fi

	    done <<< "$pkg_deps"

	fi
exit 255
    done < "$core_pkg_list"
}


main ()
{
    get_args $@
    #create_package_list
    copy_packages
    #main
}

main
