#!/bin/bash

# Check if script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root. Exiting."
   exit 1
fi

# Backup existing SSH host keys
mkdir -p /etc/ssh/backup
cp /etc/ssh/ssh_host_* /etc/ssh/backup/

# Remove existing SSH host keys
rm /etc/ssh/ssh_host_*

# Generate new SSH host keys
dpkg-reconfigure openssh-server

echo "SSH host keys regenerated. Ensure to update the authorized keys on the clients."