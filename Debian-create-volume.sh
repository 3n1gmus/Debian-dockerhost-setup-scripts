#!/bin/bash

# Check if script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root. Exiting."
   exit 1
fi

# Specify the device path (e.g., /dev/sdb, /dev/nvme0n1p1)
device="/dev/sdb"

# Specify the mount point
mount_point="/mnt/new_volume"

# Create a file system (you may adjust the filesystem type, e.g., ext4, xfs)
mkfs.ext4 "$device"

# Create the mount point directory
mkdir -p "$mount_point"

# Get the device UUID for persistent mounting
uuid=$(blkid -s UUID -o value "$device")

# Backup /etc/fstab
cp /etc/fstab /etc/fstab.bak

# Add an entry to /etc/fstab for persistent mounting
echo "UUID=$uuid $mount_point ext4 defaults 0 0" >> /etc/fstab

# Mount the volume
mount -a

echo "New volume created, formatted, and persistently mounted at $mount_point."