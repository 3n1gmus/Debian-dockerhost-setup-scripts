#!/bin/bash

# Check if script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root. Exiting."
   exit 1
fi


# Specify the desired SSH IP address
# specific_ip="your_desired_ip"

# Update the system
apt update
apt upgrade -y

# Install necessary packages
apt install -y fail2ban apparmor-utils iptables-persistent

# Secure SSH configuration
# sed -i "s/#ListenAddress 0.0.0.0/ListenAddress $specific_ip" /etc/ssh/sshd_config
sed -i 's/#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
systemctl restart ssh

# Set strong password policies
apt install -y libpam-pwquality
sed -i '/pam_pwquality.so/s/$/ retry=3/' /etc/security/pwquality.conf
sed -i '/pam_pwquality.so/s/$/ minlen=12/' /etc/security/pwquality.conf
sed -i '/pam_pwquality.so/s/$/ ucredit=-1/' /etc/security/pwquality.conf
sed -i '/pam_pwquality.so/s/$/ dcredit=-1/' /etc/security/pwquality.conf
sed -i '/pam_pwquality.so/s/$/ ocredit=-1/' /etc/security/pwquality.conf
sed -i '/pam_pwquality.so/s/$/ lcredit=-1/' /etc/security/pwquality.conf

# Configure automatic security updates
apt install -y unattended-upgrades
echo 'APT::Periodic::Update-Package-Lists "1";' | tee -a /etc/apt/apt.conf.d/20auto-upgrades
echo 'APT::Periodic::Download-Upgradeable-Packages "1";' | tee -a /etc/apt/apt.conf.d/20auto-upgrades
echo 'APT::Periodic::AutocleanInterval "7";' | tee -a /etc/apt/apt.conf.d/20auto-upgrades
echo 'APT::Periodic::Unattended-Upgrade "1";' | tee -a /etc/apt/apt.conf.d/20auto-upgrades
systemctl restart unattended-upgrades

# Configure fail2ban
systemctl enable fail2ban
systemctl start fail2ban

# Configure iptables rules for Docker
# iptables -A FORWARD -i docker0 -o eth0 -j ACCEPT
# iptables -A FORWARD -i eth0 -o docker0 -j ACCEPT
# iptables-save > /etc/iptables/rules.v4

echo "Security script executed. Please review and customize further as needed."