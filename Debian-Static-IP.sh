#!/bin/bash

# Check if script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root. Exiting."
   exit 1
fi

# Network interface and static IP configuration
interface="eth0"  # Change this to your network interface, e.g., eth0, ens33

ip_address="192.168.1.100"  # Change this to your desired static IP address
netmask="255.255.255.0"     # Change this to your netmask
gateway="192.168.1.1"       # Change this to your gateway
dns_servers="8.8.8.8 8.8.4.4"  # Change this to your DNS servers

# Backup existing network configuration files
cp /etc/network/interfaces /etc/network/interfaces.bak

# Configure static IP address
echo -e "auto $interface\niface $interface inet static\n\taddress $ip_address\n\tnetmask $netmask\n\tgateway $gateway\n" | tee /etc/network/interfaces

# Configure DNS servers
echo -e "nameserver $dns_servers" | tee /etc/resolv.conf

# Restart the networking service
systemctl restart networking

echo "Static IP address configured for $interface. Network interface will be restarted."