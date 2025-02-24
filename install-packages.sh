#! /usr/bin/env sh


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


# packages below come from apps

define_core_applications ()
{
    wayland='dotool qt6-wayland tofi wev wlroots xorg-xwayland'
    ## qt5-wayland to prevent:
    ## WARNING: Could not find the Qt platform plugin 'wayland' in
    ## i.e. when starting qutebrowser
    ## dotool for speech-to-text and yank-buffer
    #'qt5-wayland'

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

    audio='alsa-utils pipewire pipewire-alsa pipewire-jack pipewire-pulse sof-firmware'
    #'pulseaudio pulseaudio-alsa pulsemixer qpwgraph-qt5'

    image_viewers='sxiv feh imv'
    #'fim ueberzug geekie'

    bluetooth='bluez bluez-utils pulseaudio-bluetooth'
}


define_additional_tools ()
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


create_core_applications_list ()
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
			  yay \
	)
}


main ()
{
    define_core_applications
    create_core_applications_list

    define_additional_tools
    create_additional_tools_list

    create_aur_applications_list
}

main
