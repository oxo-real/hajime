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
    wayland='dotool qt5-wayland qt6-wayland wev wlroots xorg-xwayland'
    ## qt5-wayland to prevent:
    ## WARNING: Could not find the Qt platform plugin 'wayland' in
    ## i.e. when starting qutebrowser
    ## dotool for speech-to-text
    #ydotool'

    dwm='i3blocks sway swaybg swayidle swaylock swaynagmode'
    #'waybar'

    shell='zsh'

    shell_additions='zsh-completions zsh-syntax-highlighting'

    terminal='alacritty foot tmux'
    #'zellij byobu termite-nocsd urxvt'

    terminal_additions='bat eza delta fzf fzf-tab-git getoptions mako pv'
    #'wofi rofi bemenu-wayland'

    manpages='man-db man-pages tldr'

    password_security='pass pass-otp yubikey-manager'
    #'pass-tomb bitwarden-cli pass-wl-clipboard'

    encryption='gnupg ssss'
    #'veracrypt tomb'

    security='opendoas arch-audit'

    secure_connections='wireguard-tools protonvpn-cli-ng sshfs'

    filesystems='dosfstools ntfs-3g'

    fonts='otf-unifonts'
    #'ttf-unifonts terminus-font ttf-inconsolata'

    display='brightnessctl'

    input_devices='zsa-wally-cli wvkbd'

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

    file_tools='rsync gdisk simple-mtpfs fd dust'
    #'tmsu trash-cli'

    debugging='strace'
    #'gdb valgrind'

    network_tools='mtr iftop bind-tools whois ufw trippy'
    #'wireshark-cli wireshark-qt'

    prog_langs=#''
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

    download_utilities='aria2 transmission-cli transmission-remote-cli-git'

    system_info='lshw usbutils'

    system_monitoring='btop glances viddy'
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

    video_tools='yt-dlp mpv pipe-viewer'
    #'straw-viewer youtube-viewer youtube-dl'

    photo_editing=''
    #'gimp'

    photo_management=''
    #'digikam darktable'

    vector_graphics_editing=''
    #'inkscape'

    office_tools='presenterm'
    #'libreoffice-fresh mdp'

    cad=''
    #'freecad'

    navigation='gpsbabel viking'
    #'qgis grass stellarium'

    weather=''
    #'wttr'

    database='sqlitebrowser arch-wiki-docs arch-wiki-lite'

}


mount_repo()
{
    repo_lbl='REPO'
    repo_dev=$(lsblk -o label,path | grep "$repo_lbl" | awk '{print $2}')

    [[ -d $repo_dir ]] || mkdir -p "$repo_dir"

    mountpoint -q $repo_dir
    [[ $? -eq 0 ]] || sudo mount "$repo_dev" "$repo_dir"
}


get_offline_repo()
{
    case $offline in
	1)
	    mount_repo
	    ;;
    esac
}


mount_code()
{
    code_lbl='CODE'
    code_dev=$(lsblk -o label,path | grep "$code_lbl" | awk '{print $2}')

    [[ -d $code_dir ]] || mkdir -p "$code_dir"

    mountpoint -q $code_dir
    [[ $? -eq 0 ]] || sudo mount "$code_dev" "$code_dir"
}


get_offline_code()
{
    case $offline in
	1)
	    mount_code
	    ;;
    esac
}


install_yay()
{
    ## install yay
    package='yay'
    current_package_dir="$aur_dir/$package"
    c_p_newest_version=$(ls $current_package_dir/*.pkg.tar.zst --reverse --sort=version | grep -v 'debug' | sed -n 1p)

    sudo pacman -U --noconfirm $c_p_newest_version
}


install_aur()
{
    ## install aur packages
    ## [Offline installation - ArchWiki]
    ## (https://wiki.archlinux.org/title/Offline_installation#Install_from_file)
    for package in $(ls $aur_dir); do

	## yay is already installed
	if [[ "$package" != "yay" ]]; then

	    current_package_dir="$aur_dir/$package"
	    c_p_newest_version=$(ls $current_package_dir/*.pkg.tar.zst --reverse --sort=version | sed -n 1p)

	    yay -U --noconfirm $c_p_newest_version

	else

	    continue

	fi

    done

    ## generate a development package database
    yay -Y --gendb

    ## update local repo
    yay -Syy
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
			  calcmysky \
			  cava \
			  dotool \
			  fzf-tab-git \
			  lisp \
			  mbrola \
			  md2pdf-git \
			  ncurses5-compat-libs \
			  nerd-dictation-git \
			  obs-backgroundremoval \
			  otf-unifont \
			  presenterm-bin \
			  qpwgraph-qt5 \
			  qt5-webkit \
			  simple-mtpfs \
			  ssss \
			  stellarium \
			  swaynagmode \
			  ttf-unifont \
			  viddy \
			  virtualbox-ext-oracle \
			  vosk-api \
			  wev \
			  wlrobs \
			  wttr \
			  yay \
	)
}


set_usr_rw()
{
    ## set /usr writeable
    sudo mount -o remount,rw  /usr
}


set_usr_ro()
{
    # reset /usr read-only
    sudo mount -o remount,ro  /usr
}


install_core_applications()
{
    ## loop through core app packages
    ## instead of one whole list entry in yay
    ## this prevents that on error only one package is skipped
    #local packages=$(echo "${core_applications[*]}")
    #sudo pacman -S --noconfirm --needed $packages
    for pkg_ca in "${core_applications[@]}"; do

	sudo pacman -S --needed --noconfirm "$pkg_ca"
	#sudo pacman -S --noconfirm --needed "$pkg_ca"

    done
}


install_additional_tools()
{
    ## loop through core app packages
    ## instead of one whole list entry in yay
    ## this prevents that on error only one package is skipped
    #local packages=$(echo "${additional_tools[*]}")
    #sudo pacman -S --noconfirm --needed $packages
    for pkg_at in "${additional_tools[@]}"; do

	sudo pacman -S --needed --noconfirm "$pkg_at"
	#sudo pacman -Sy --noconfirm --needed "$pkg_at"

    done
}


install_aur_applications()
{
    ## loop through core app packages
    ## instead of one whole list entry in yay
    ## this prevents that on error only one package is skipped
    #local packages=$(echo "${additional_tools[*]}")
    #sudo pacman -S --noconfirm --needed $packages
    for pkg_aa in "${aur_applications_list[@]}"; do

	yay -S --needed --noconfirm "$pkg_aa"
	#sudo pacman -Sy --noconfirm --needed "$pkg_aa"

    done
}


loose_ends()
{
    #[TODO]remove candidate
    ## tmux_plugin_manager
    #tmux_plugin_dir="$HOME/.config/tmux/plugins"
    #git clone https://github.com/tmux-plugins/tpm $tmux_plugin_dir/tpm

    #[TODO]remove candidate
    ## create w3mimgdisplay symlink
    ## w3mimgdisplay is not in /usr/bin by default as of 20210114
    ## alternative is to add /usr/lib/w3m to $PATH
    #sudo ln -s /usr/lib/w3m/w3mimgdisplay /usr/bin/w3mimgdisplay

    ## recommend human to execute dotfiles install script
    echo 'sh hajime/5dtcf.sh'

    ## finishing
    sudo touch $HOME/hajime/4apps.done
}


main() {
    define_core_applications
    create_core_applications_list

    define_additional_tools
    create_additional_tools_list

    create_aur_applications_list

    set_usr_rw
    get_offline_repo
    get_offline_code

    install_core_applications
    install_additional_tools
    install_aur_applications

    loose_ends
    set_usr_ro
}

main
