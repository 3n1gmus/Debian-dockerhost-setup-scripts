#!/bin/bash

# 1. Nuke old service if it exists
echo "Cleaning up old service..."
sudo systemctl stop holesail.service 2>/dev/null
sudo systemctl disable holesail.service 2>/dev/null
sudo rm -f /etc/systemd/system/holesail.service
sudo systemctl daemon-reload

# 2. Setup New Service
echo "--- Holesail Secure SSH Setup ---"

# EXACT z32 alphabet: ybndrfszgctmqpkhxwjicalsurotkpey
# Removed: l, v, 0, 1, 8, 9
Z32_ALPHABET="ybndrfszgctmqpkhxwjicalsurotkpey"
HOLESAIL_KEY=$(LC_ALL=C tr -dc "$Z32_ALPHABET" < /dev/urandom | head -c 32)

read -p "Enter SSH Port (default 22): " SSH_PORT
SSH_PORT=${SSH_PORT:-22}

# 3. Create service file
sudo bash -c "cat > /etc/systemd/system/holesail.service" <<EOF
[Unit]
Description=Holesail SSH Tunnel
After=network.target

[Service]
ExecStart=/usr/local/bin/holesail --live $SSH_PORT --key $HOLESAIL_KEY
Restart=always
RestartSec=10
User=root

[Install]
WantedBy=multi-user.target
EOF

# 4. Start
sudo systemctl daemon-reload
sudo systemctl enable holesail.service
sudo systemctl start holesail.service

echo "-----------------------------------------------"
echo "SUCCESS: Holesail is running."
echo "YOUR VALID KEY: $HOLESAIL_KEY"
echo "-----------------------------------------------"
echo "Connect with: holesail $HOLESAIL_KEY --port 2222"