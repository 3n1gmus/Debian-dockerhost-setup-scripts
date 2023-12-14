#!/bin/bash

# Update package lists
sudo apt-get update

# Install unattended-upgrades
sudo apt-get install -y unattended-upgrades

# Configure automatic updates
echo 'APT::Periodic::Update-Package-Lists "1";' | sudo tee -a /etc/apt/apt.conf.d/20auto-upgrades
echo 'APT::Periodic::Download-Upgradeable-Packages "1";' | sudo tee -a /etc/apt/apt.conf.d/20auto-upgrades
echo 'APT::Periodic::AutocleanInterval "7";' | sudo tee -a /etc/apt/apt.conf.d/20auto-upgrades
echo 'APT::Periodic::Unattended-Upgrade "1";' | sudo tee -a /etc/apt/apt.conf.d/20auto-upgrades

# Restart the unattended-upgrades service
sudo systemctl restart unattended-upgrades

echo "Automatic updates are now enabled. The system will check for updates daily."