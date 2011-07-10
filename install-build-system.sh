#!/usr/bin/bash
packages="pkg:/file/gnu-coreutils pkg:/SFEcmake pkg:/SFEemacs pkg:/SFEgcc pkg:/SFEgcc-46 pkg:/SFEgcc-46-runtime pkg:/SFEgccruntime pkg:/SFEgit pkg:/developer/build/gnu-make pkg:/developer/build/gnu-make pkg:/developer/library/lint pkg:/developer/versioning/subversion pkg:/text/gnu-grep"

if [ $# -ne 1 ]; then
    echo "Please supply a zone name."
    exit 1
fi

if [ $UID -ne 0 ]; then
    echo "Not run as root"
    exit 2
fi

name=$1

if [ -e /etc/zones/$name.xml ]; then
    echo "Halting $name..."
    zoneadm -z $name halt &> /dev/null
    echo "Installing the packages..."
    pkg -R /zones/$name/root install $packages
    echo "Booting up..."
    zoneadm -z $name boot &> /dev/null
    echo "Done."
else
    echo "Zone $name doesn't have a config"
    exit 3
fi
