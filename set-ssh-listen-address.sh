#!/bin/bash

# Check if script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root. Exiting."
   exit 1
fi

# Specify the desired IP address
specific_ip="your_desired_ip"

# Backup the original sshd_config
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak

# Update sshd_config to listen on the specific IP address
sed -i "/^ListenAddress/c\ListenAddress $specific_ip" /etc/ssh/sshd_config

# Restart the SSH service to apply changes
systemctl restart ssh

echo "SSH server now configured to listen only on $specific_ip."