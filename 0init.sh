#! /usr/bin/env sh

###  _            _ _                  _       _ _
### | |__   __ _ (_|_)_ __ ___   ___  (_)_ __ (_) |_
### | '_ \ / _` || | | '_ ` _ \ / _ \ | | '_ \| | __|
### | | | | (_| || | | | | | | |  __/ | | | | | | |_
### |_| |_|\__,_|/ |_|_| |_| |_|\___| |_|_| |_|_|\__|0
###            |__/
###
###  # # # # # #
###       #
###  # # # # # #
###

: '
hajime_0init
initial part of linux installation
copyright (c) 2020 - 2025  |  oxo

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
initial part of five scripts in total
helper script to bootstrap hajime after archiso boot

# dependencies
  REPO

# usage
  sh hajime/0init.sh [--offline|online|hybrid] [--config $custom_conf_file]

# example
  mkdir tmp
  lsblk
  mount /dev/sdX tmp
  sh tmp/code/hajime/0init.sh -c tmp/code/hajime/setup/dl3189.conf

# '


#set -o errexit
#set -o nounset
set -o pipefail

# initial definitions

## script
script_name=0init.sh
developer=oxo
license=gplv3
initial_release=2020

## point in time
pit=0

## absolute file paths
hajime_src=/root/tmp/code/hajime


#--------------------------------


args="$@"
getargs ()
{
    while :; do

	case "$1" in

	    -c | --config )
		shift

		## get config flag value
		cfv="$1"

		process_config_flag_value
		shift
		;;

	    --offline )
		## explicit arguments overrule defaults or configuration file setting

		## offline installation
		[[ "$1" =~ offline$ ]] && offline_arg=1 && online=0
		shift
		;;

	    --online )
		## explicit arguments overrule defaults or configuration file setting

		## online installation
		[[ "$1" =~ online$ ]] && online_arg=1 && online="$online_arg"
		shift
		;;

	    --hybrid )
		## explicit arguments overrule defaults or configuration file setting

		## hybrid installation
		[[ "$1" =~ hybrid$ ]] && online_arg=2 && online="$online_arg"
		shift
		;;

	    --pit )
		shift

		## get pit flag value
		pit="$1"
		shift
		;;

	    - )
		shift

		## get config flag value
		cfv="$1"

		process_config_flag_value
		break
		;;

            * )
		break
		;;

	esac

    done
}


sourcing ()
{
    ## script_name is used in file_setup_config

    export script_name

    if [[ "$pit" -eq 0 ]]; then

	hajime_exec=/root/hajime

    fi

    ## runmode (for informative text)
    if [[ "$online" -eq 0 ]]; then

	runmode=offline

    elif [[ "$online" -eq 1 ]]; then

	runmode=online

    elif [[ "$online" -eq 2 ]]; then

	runmode=hybrid

    fi

    ## configuration file
    ### define
    #    via --config argument value
    ### source
    [[ -f "$file_setup_config" ]] && source "$file_setup_config"

    relative_file_paths

    ## config file is sourced; reevaluate explicit arguments
    explicit_arguments
}


relative_file_paths ()
{
    ## independent (i.e. no if) relative file paths

    if [[ "$pit" -eq 0 ]]; then

	## tempo-active.conf contains path to active setup configuration file
	file_setup_config_path="$hajime_src"/setup/tempo-active.conf
	printf '%s\n' "$(realpath "$file_setup_config")" > "$file_setup_config_path"

    fi

    ## wireless network access point password
    wap_pass="$hajime_src"/setup/wap"$wap".pass

    if [[ "$pit" -gt 0 ]]; then

	file_setup_config_path="$hajime_exec"/setup/tempo-active.conf
	wap_pass="$hajime_exec"/setup/wap"$wap".pass

    fi
}


explicit_arguments ()
{
    ## explicit arguments override default and configuration settings
    ## regarding network installation mode

    if [[ "$offline_arg" -eq 1 ]]; then
	## offine mode (forced)

	online=0

	## change network mode in configuration file
	## uncomment line online=0
	sed -i '/online=0/s/^[ \t]*#\+ *//' "$file_setup_config"
	## comment line online=1
	sed -i '/^online=1/ s/./#&/' "$file_setup_config"
	## comment line online=2
	sed -i '/^online=2/ s/./#&/' "$file_setup_config"

    elif [[ "$online_arg" -eq 1 ]]; then
	## online mode (forced)

	online=1

	## change network mode in configuration file
	## comment line online=0
	sed -i '/^online=0/ s/./#&/' "$file_setup_config"
	## uncomment line online=1
	sed -i '/online=1/s/^[ \t]*#\+ *//' "$file_setup_config"
	## comment line online=2
	sed -i '/^online=2/ s/./#&/' "$file_setup_config"

    elif [[ "$online_arg" -eq 2 ]]; then
	## hybrid mode (forced)

	online=2

	## change network mode in configuration file
	## comment line online=0
	sed -i '/^online=0/ s/./#&/' "$file_setup_config"
	## comment line online=1
	sed -i '/^online=1/ s/./#&/' "$file_setup_config"
	## uncomment line online=2
	sed -i '/online=2/s/^[ \t]*#\+ *//' "$file_setup_config"

    fi
}


process_config_flag_value ()
{
    realpath_cfv=$(realpath "$cfv")

    if [[ -f "$realpath_cfv" ]]; then

	file_setup_config="$realpath_cfv"

    else

	printf 'ERROR config file ${st_bold}%s${st_def} not found\n' "$cfv"

	unset file_setup_config
	unset realpath_cfv
	unset cfv

	exit 151

    fi
}


define_text_appearance()
{
    ## text color
    fg_magenta='\033[0;35m'	# magenta
    fg_green='\033[0;32m'	# green
    fg_red='\033[0;31m'		# red

    ## text style
    st_def='\033[0m'		# default
    st_ul=`tput smul`		# underline
    st_bold=`tput bold`		# bold
}


reply_single ()
{
    # reply_functions

    # first entered character goes directly to $reply
    stty_0=$(stty -g)
    stty raw #-echo
    reply=$(head -c 1)
    stty $stty_0
}


header ()
{
    [[ "$pit" -eq 0 ]] && clear
    current_year="$(date +%Y)"
    printf 'hajime - %s\n' "$script_name"
    printf 'copyright (c) %s' "$initial_release"
    [[ $initial_release -ne $current_year ]] && printf ' - %s' "$current_year"
    printf '  |  %s\n' "$developer"
    echo
    echo
}


config_file_warning ()
{
    if [[ "$pit" -eq 0 && -n "$file_setup_config" ]]; then

	printf "${st_bold}CAUTION!${st_def}\n"
	printf "active configuration file  ${st_ul}%s${st_def}\n" "$file_setup_config"
	echo
	printf "this file WILL be used for ${fg_magenta}automatic installation${st_def}\n"
	echo
	printf "hajime repository source   ${st_bold}%s${st_def}\n" "$runmode"
	echo
	echo
	printf 'before continuing, be 100%% sure that:\n'
	echo
	printf "1. the file designates this machine, and\n"
	printf "2. all the parameters in the file are correct\n"
	echo
	echo
	printf "${fg_magenta}continue${st_def} with automatic installation? [y/N] "

	reply_single
	echo

	if printf "$reply" | grep -iq "^y"; then

	    :

	else

	    printf 'installation aborted by user\n'
	    exit 1

	fi

    fi
}


check_network_connection ()
{
    ping -D -i 1 -c 3 9.9.9.9 > /dev/null 2>&1
}


select_network_interface ()
{
    echo
    ip a
    echo

    printf "please enter network interface number: "
    read interface_number

    # translate number to interface name
    interface=$(ip a \
		    | grep "^$interface_number" \
		    | awk '{print $2}' \
		    | sed 's/://'
	     )
}


set_interface_up ()
{
    sudo ip link set "$interface" up
}


setup_wap ()
{
    echo

    ## awk removes leading and trailing whitespace
    ## nl adds line numbers
    wap_list=$(sudo iw dev $interface scan \
		   | grep SSID: \
		   | sed 's/SSID: //' \
		   | awk '{$1=$1;print}' \
		   | sort \
		   | uniq \
		   | sort \
		   | nl
	    )

    if [[ "$(wc -l <<< "#wap_list")" -eq 0 ]]; then

	printf 'ERROR no wireless access points found\n'
	exit 34

    fi

    printf 'available wireless access points (wap):\n'
    printf '%s\n' "$wap_list"
    echo

    printf 'enter number to connect to wap: '
    read wap_number

    wap=$(echo "$wap_list" \
	      | awk '{if ($1=='"$wap_number"') {print $2}}'
       )

    echo

    if [[ ! -f "$wap_pass" ]]; then

	printf 'enter password for %s: ' "$wap"
	## create wireless connection configuration file
	sudo wpa_passphrase "$wap" > "$wap_pass"
	echo

    fi

    sudo wpa_supplicant -B -i $interface -c "$wap_pass"
}


dhcp_connect ()
{
    sudo dhcpcd -w "$interface"

    for i in {15..0}; do

	printf 'dhcpcd connect %s %d\r' "$interface" "$i"
	sleep 1

    done
    echo

    printf '%s connected' "$interface"
    [[ -n "$wap" ]] && printf ' to %s' "$wap"
    echo
}


network_connect ()
{
    check_network_connection

    if [[ $? -ne 0 ]]; then

	select_network_interface
	set_interface_up
	[[ "$interface" =~ ^w ]] && setup_wap
	dhcp_connect

    fi
}


roadmap ()
{
    if [[ "$pit" -gt 0 ]]; then

	## entry point modules to connect to a network
	network_connect

    else

	point_in_time
	copy_hajime
	installation_mode
	autostart_next

    fi
}


point_in_time ()
{
    ## CODE and REPO mountpoints
    ## "$HOME"/dock/{2,3} are not available yet
    ## therefore set /root/tmp as mountpoint
    code_lbl=CODE
    code_dir=/root/tmp/code
    repo_lbl=REPO
    repo_dir=/root/tmp/repo
    repo_re=\/root\/tmp\/repo
}


copy_hajime ()
{
    ## copy from hajime_src to hajime exec
    ## from hajime_exec the script will continue to run
    echo
    printf 'copying hajime to /root '
    cp --preserve --recursive "$code_dir"/hajime /root
    echo
    echo
}


installation_mode ()
{
    if [[ -n "$exec_mode" ]]; then
	## configuration file

	## update file_setup_config_path with it's new hajime_exec location
	## hajime_exec did not exist before cp, we define it here
	## export for availability in 1base
	export hajime_exec=/root/hajime
	file_setup_config_path="$hajime_exec"/setup/tempo-active.conf
	## file_setup_config_exec = file_setup_config_path in hajime_exec
	file_setup_config_exec=$(realpath $(find "$hajime_exec"/setup -iname $(basename "$file_setup_config")))

	## write file_setup_config_path with hajime_exec location
	printf '%s\n' "$file_setup_config_exec" > "$file_setup_config_path"

    fi

    if [[ "$online" -ne 1 ]]; then
	## offline or hybrid mode

	## mount repo
	get_offline_repo

    fi

    if [[ "$online" -ne 0 ]]; then
	## online or hybrid mode

	network_connect

    fi

    touch /root/hajime/0init.done

    echo
    printf 'sh hajime/1base.sh\n'
    echo
}


mount_repo ()
{
    # repo_lbl='REPO'
    repo_dev=$(lsblk -o label,path | grep "$repo_lbl" | awk '{print $2}')

    [[ -d "$repo_dir" ]] || mkdir -p "$repo_dir"

    mountpoint -q "$repo_dir"
    [[ $? -ne 0 ]] && sudo mount "$repo_dev" "$repo_dir"
}


get_offline_repo ()
{
    mount_repo

    if [[ -z "$repo_dev" ]]; then

	printf 'ERROR device REPO not found\n'
	exit 30

    fi
}


autostart_next ()
{
    ## switch autostart via configuration file
    [[ -n "$after_0init" ]] && sh /root/hajime/1base.sh
}


main ()
{
    getargs $args
    sourcing
    define_text_appearance
    header
    config_file_warning
    roadmap
}

main
