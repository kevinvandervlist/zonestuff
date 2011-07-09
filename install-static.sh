#!/usr/bin/bash
nic=rge0
domain=vdv
dns=192.168.111.1
defrouter=192.168.111.254
netmask=255.255.255.0
netmask_short=/24
terminal=xterm
autoboot=false

if [ $# -ne 2 ]; then
    echo "Please supply a zone name and an IP address."
    exit 1
fi

if [ $UID -ne 0 ]; then
    echo "Not run as root"
    exit 2
fi

name=$1
ipaddr=$2

if [ -e /etc/zones/$name.xml ]; then
    echo "Zone $name allready has a config"
    exit 3
fi

echo "Give a root password"
root=$(openssl passwd)

echo "Configuring $name.xml..."

zonecfg -z $name << EOF &> /dev/null
  create
  set zonepath=/zones/$name
  set autoboot=$autoboot
  add net
  set physical=$nic
  set address=${ipaddr}${netmask_short}
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
network_interface=primary {hostname=$name ip_address=$ipaddr netmask=$netmask default_route=$defrouter protocol_ipv6=no}" > /tmp/$name.tmp

mv /tmp/$name.tmp /zones/$name/root/etc/sysidcfg

echo "Booting zone $name..."

zoneadm -z $name boot

$terminal -e zlogin -C $name
echo "Done. Login with zlogin $name ."
echo "Remove /etc/sysidcfg after login."

exit 0
