#!/bin/bash

set -x
#set -xeuo pipefail

if [[ $(id -u) -ne 0 ]] ; then
    echo "Must be run as root"
    exit 1
fi

if [ $# != 3 ]; then
    echo "Usage: $0 <MasterHostname> <mountFolder> <numDataDisks> "
    exit 1
fi

# Set user args
MASTER_HOSTNAME=$1

# Shares
#MNT_POINT="$2"
#SHARE_DATA=$MNT_POINT/data
numberofDisks="$3"

setup_dynamicdata_disks()
{
    mountPoint="$1"
    createdPartitions=""

    # Loop through and partition disks until not found

if [ "$numberofDisks" == "1" ]; then
disking=( sdc )
elif [ "$numberofDisks" == "2" ]; then
disking=( sdc sdd )
elif [ "$numberofDisks" == "3" ]; then
disking=( sdc sdd sde )
elif [ "$numberofDisks" == "4" ]; then
disking=( sdc sdd sde sdf )
elif [ "$numberofDisks" == "5" ]; then
disking=( sdc sdd sde sdf sdg )
elif [ "$numberofDisks" == "6" ]; then
disking=( sdc sdd sde sdf sdg sdh )
elif [ "$numberofDisks" == "7" ]; then
disking=( sdc sdd sde sdf sdg sdh sdi )
elif [ "$numberofDisks" == "8" ]; then
disking=( sdc sdd sde sdf sdg sdh sdi sdj )
elif [ "$numberofDisks" == "9" ]; then
disking=( sdc sdd sde sdf sdg sdh sdi sdj sdk )
elif [ "$numberofDisks" == "10" ]; then
disking=( sdc sdd sde sdf sdg sdh sdi sdj sdk sdl )
elif [ "$numberofDisks" == "11" ]; then
disking=( sdc sdd sde sdf sdg sdh sdi sdj sdk sdl sdm )
elif [ "$numberofDisks" == "12" ]; then
disking=( sdc sdd sde sdf sdg sdh sdi sdj sdk sdl sdm sdn )
elif [ "$numberofDisks" == "13" ]; then
disking=( sdc sdd sde sdf sdg sdh sdi sdj sdk sdl sdm sdn sdo )
elif [ "$numberofDisks" == "14" ]; then
disking=( sdc sdd sde sdf sdg sdh sdi sdj sdk sdl sdm sdn sdo sdp )
elif [ "$numberofDisks" == "15" ]; then
disking=( sdc sdd sde sdf sdg sdh sdi sdj sdk sdl sdm sdn sdo sdp sdq )
elif [ "$numberofDisks" == "16" ]; then
disking=( sdc sdd sde sdf sdg sdh sdi sdj sdk sdl sdm sdn sdo sdp sdq sdr )
fi

printf "%s\n" "${disking[@]}"

for disk in "${disking[@]}"
do
        fdisk -l /dev/$disk || break
        fdisk /dev/$disk << EOF
n
p
1


t
fd
w
EOF
        createdPartitions="$createdPartitions /dev/${disk}1"
    done

        # Create RAID-0 volume
        if [ -n "$createdPartitions" ]; then
            #devices=`echo $createdPartitions | wc -w`
            
            #mdadm --create /dev/md10 --level 0 --raid-devices $devices $createdPartitions
            mkfs -t ext4 /dev/${disk}1
            mkdir $mountPoint
            mount /dev/${disk}1  $mountPoint
            
            blockid=$(/sbin/blkid|grep ${disk}|awk '{print $2}'|awk -F\= '{print $2}'|sed -e"s/\"//g")

            #mount -o defaults,noatime "${device}" "${mount}"
            # Set up the blkid for device entry in /etc/fstab
            echo "UUID=${blockid} $mountPoint ext4 defaults,nofail 0 2" >> /etc/fstab
            #echo "/dev/md10 $mountPoint ext4 defaults,nofail 0 2" >> /etc/fstab
            sudo chmod go+w $mountPoint
        fi
}

setup_dynamicdata_disks $2
