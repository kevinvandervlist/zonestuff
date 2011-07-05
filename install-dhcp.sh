#!/usr/bin/bash
nic=e1000g0
domain=lan
dns=145.24.129.1
terminal=xterm
autoboot=false

if [ $# -ne 1 ]; then
    echo "Please supply a zone name"
    exit 1
fi

name=$1

if [ -e /etc/zones/$name.xml ]; then
    echo "Zone $name allready has a config"
    exit 2
fi

echo "Give a root password"
root=$(openssl passwd)

vnic="zv_${name}0"
echo "Attaching virtual $vnic to $nic"
dladm create-vnic -l $nic $vnic

echo "Configuring $name.xml..."

zonecfg -z $name << EOF &> /dev/null
  create
  set zonepath=/zones/$name
  set autoboot=$autoboot
  set ip-type=exclusive
  add net
  set physical=$vnic
  end
  commit
  exit
EOF

echo "Installing zone $name..."

zoneadm -z $name install &> /dev/null

echo "Configuring zone $name..."

echo "keyboard=US-English
system_locale=C
timezone=Europe/Amsterdam
terminal=xterm
root_password=$root
security_policy=none
nfs4_domain=dynamic
name_service=DNS {domain_name=$domain name_server=$dns}
network_interface=primary {dhcp protocol_ipv6=no}" > /tmp/$name.tmp

mv /tmp/$name.tmp /zones/$name/root/etc/sysidcfg

echo "Booting zone $name..."

zoneadm -z $name boot

$terminal -e zlogin -C $name
echo "Done. Login with zlogin $name ."
echo "Remove /etc/sysidcfg after login."

exit 0
