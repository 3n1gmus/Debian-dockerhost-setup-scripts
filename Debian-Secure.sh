#!/bin/bash

# Ensure script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root. Exiting." >&2
   exit 1
fi

echo "Starting system hardening..."

# 1. Non-interactive frontend for automated apt commands
export DEBIAN_FRONTEND=noninteractive

# 2. Update and Upgrade System
apt-get update
apt-get dist-upgrade -y

# 3. Install Security Packages
apt-get install -y fail2ban apparmor-utils ufw libpam-pwquality unattended-upgrades

# 4. Secure SSH Configuration (Using modern drop-in files)
echo "Configuring SSH security..."
cat <<EOF > /etc/ssh/sshd_config.d/99-hardening.conf
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes
X11Forwarding no
MaxAuthTries 3
EOF

# Restart SSH to apply changes safely
if sshd -t; then
    systemctl restart ssh
else
    echo "Warning: SSH configuration test failed. Not restarting SSH." >&2
fi

# 5. Set Strong Password Policies
echo "Configuring password quality requirements..."
cat <<EOF > /etc/security/pwquality.conf
# Set password complexity requirements
minlen = 12
retry = 3
ucredit = -1
dcredit = -1
ocredit = -1
lcredit = -1
EOF

# 6. Configure Automatic Security Updates
echo "Configuring unattended-upgrades..."
cat <<EOF > /etc/apt/apt.conf.d/20auto-upgrades
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Download-Upgradeable-Packages "1";
APT::Periodic::AutocleanInterval "7";
APT::Periodic::Unattended-Upgrade "1";
EOF

systemctl restart unattended-upgrades

# 7. Configure Firewall (UFW) & Fail2ban
echo "Configuring Firewall and Fail2ban..."

# Setup local jail for Fail2ban
cat <<EOF > /etc/fail2ban/jail.local
[sshd]
enabled = true
port = ssh
filter = sshd
logpath = %(sshd_log)s
maxretry = 3
bantime = 1h
EOF

systemctl enable --now fail2ban

# Setup UFW (Safely allow SSH before enabling)
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
ufw --force enable

echo "--------------------------------------------------------"
echo "Security script executed successfully."
echo "CRITICAL: Do not close this terminal session until you"
echo "test logging in via a NEW terminal to verify SSH works!"
echo "--------------------------------------------------------"