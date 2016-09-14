#!/bin/bash

set -x
#set -xeuo pipefail

if [[ $(id -u) -ne 0 ]] ; then
    echo "Must be run as root"
    exit 1
fi
mountPoint="/datadrive"
disk=sdc

fdisk -l /dev/sdc || break
fdisk /dev/sdc << EOF
n
p
1


t
fd
w
EOF

mkfs -t ext4 /dev/sdc1
mkdir $mountPoint
mount /dev/$disk1  $mountPoint

blockid=$(/sbin/blkid|grep $disk|awk '{print $2}'|awk -F\= '{print $2}'|sed -e"s/\"//g")
# Set up the blkid for device entry in /etc/fstab
echo "UUID=${blockid} $mountPoint ext4 defaults, nofail   0    2" >> /etc/fstab
sudo chmod go+w $mountPoint

