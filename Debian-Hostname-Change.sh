#!/bin/bash

# Check if script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root. Exiting."
   exit 1
fi

# Set the new hostname
new_hostname="your_new_hostname"

# Change the hostname
hostnamectl set-hostname "$new_hostname"

# Update /etc/hosts with the new hostname
sed -i "s/127.0.1.1\s.*/127.0.1.1\t$new_hostname/" /etc/hosts

echo "Hostname updated to $new_hostname. Reboot the system for changes to take effect."