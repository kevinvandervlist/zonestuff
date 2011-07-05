#!/usr/bin/bash
if [ $# -ne 1 ]; then
    echo "Please supply a zone name"
    exit 1
fi

name=$1
vnic=zv_${name}0

if [ -e /etc/zones/$name.xml ]; then
    echo "Halting $name..."
    zoneadm -z $name halt &> /dev/null
    echo "Uninstalling $name..."    
    zoneadm -z $name uninstall
    echo "Removing $name.xml..."    
    rm /etc/zones/$name.xml
    echo "remove vnic $vnic"
    dladm delete-vnic $vnic
    echo "Done. Zone $name is removed"
    exit 0
else
    echo "Zone $name has no config."
    exit 2
fi