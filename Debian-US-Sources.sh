#!/bin/bash

# Check if script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root. Exiting."
   exit 1
fi

# Check if lsb_release and netselect-apt are installed and install them if not
if ! command -v lsb_release > /dev/null || ! command -v netselect-apt > /dev/null; then
    echo "Installing required packages..."
    apt update
    apt install -y lsb-release netselect-apt
fi

# Detect Debian version
debian_version=$(lsb_release -cs)

if [ -z "$debian_version" ]; then
    echo "Failed to detect Debian version. Exiting."
    exit 1
fi

# Use netselect-apt to find the fastest mirrors
echo "Finding fastest Debian mirrors in your region..."
mirrors=$(netselect-apt -c US -t 5 -a amd64 -n stable | grep -oP '(?<=Writing sources.list using)\s+(http[^\s]+)')

if [ -z "$mirrors" ]; then
    echo "Failed to find fast mirrors. Exiting."
    exit 1
fi

# Backup the original sources.list
cp /etc/apt/sources.list /etc/apt/sources.list.bak

# Add additional Debian mirrors to sources.list
echo "Adding fastest Debian mirrors to sources.list..."
echo "$mirrors" | tee -a /etc/apt/sources.list

# Update the package lists
apt update

echo "Additional Debian mirrors added to sources.list for Debian $debian_version."
