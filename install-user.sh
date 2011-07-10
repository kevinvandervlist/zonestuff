#!/usr/bin/bash
username="kevin"
group="staff"
uid=1000
gid=10

if [ $# -ne 1 ]; then
    echo "Please supply a zone name."
    exit 1
fi

if [ $UID -ne 0 ]; then
    echo "Not run as root"
    exit 2
fi

name=$1

echo "Give a user password"
passwd=$(openssl passwd)

if [ -e /etc/zones/$name.xml ]; then
    echo "Installing the user..."
    mkdir -p /zones/$name/root/export/home/$username/.ssh/
    chown -R ${username}:${group} /zones/$name/root/export/home/$username
    echo "${username}:x:${uid}:${gid}:install-user.sh:/export/home/${username}:/usr/bin/bash" >> /zones/$name/root/etc/passwd
    echo "${username}:${passwd}:6445::::::" >> /zones/$name/root/etc/shadow
    cp /zones/$name/root/etc/skel/.bashrc /zones/$name/root/export/home/$username/.
    cp /zones/$name/root/etc/skel/.profile /zones/$name/root/export/home/$username/.
    cp /zones/$name/root/etc/skel/local.profile /zones/$name/root/export/home/$username/.
    echo "Done."
else
    echo "Zone $name doesn't have a config"
    exit 3
fi
