#!/bin/bash

# Execute a command as root (or sudo)
do_with_root() {
    # already root? "Just do it" (tm).
    if [[ `whoami` = 'root' ]]; then
        $*
    elif [[ -x /bin/sudo || -x /usr/bin/sudo ]]; then
        echo "sudo $*"
        sudo $*
    else
        echo "OpenFog requires root privileges to install."
        echo "Please run this script as root."
        exit 1
    fi
}

# Detect distribution name
if [[ `which lsb_release 2>/dev/null` ]]; then
    # lsb_release available
    distrib_name=`lsb_release -is`
else
    # try other method...
    lsb_files=`find /etc -type f -maxdepth 1 \( ! -wholename /etc/os-release ! -wholename /etc/lsb-release -wholename /etc/\*release -o -wholename /etc/\*version \) 2> /dev/null`
    for file in $lsb_files; do
        if [[ $file =~ /etc/(.*)[-_] ]]; then
            distrib_name=${BASH_REMATCH[1]}
            break
        else
            echo "Sorry, OpenFog installer script is not compliant with your system."
            exit 1
        fi
    done
fi

echo "Detected system:" $distrib_name

shopt -s nocasematch

install_args=${install_args//auto/100%}

# Let's do the installation
if [[ $distrib_name == "ubuntu" ]]; then
    # Set non interactive mode
    set -eo pipefail
    export DEBIAN_FRONTEND=noninteractive
    do_with_root curl -O https://github.com/450224348/draco/blob/master/openfog -o openfog
    do_with_root chmod +x ./openfog
    do_with_root ./openfog $install_args
elif [[ $distrib_name == "redhat" || $distrib_name == "centos" || $distrib_name == "fedora" ]]; then
    # Redhat/CentOS/Fedora
    do_with_root curl -O https://github.com/450224348/draco/blob/master/openfog -o openfog
    do_with_root chmod +x ./openfog
    do_with_root ./openfog $install_args
else
    # Unsupported system
    echo "Sorry, OpenFog installer script is not compliant with your system."
    exit 1
fi
