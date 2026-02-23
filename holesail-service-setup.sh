#!/bin/bash

# 1. Cleanup old service
echo "Cleaning up old service..."
sudo systemctl stop holesail.service 2>/dev/null
sudo systemctl disable holesail.service 2>/dev/null
sudo rm -f /etc/systemd/system/holesail.service
sudo systemctl daemon-reload

# 2. Configuration
echo "--- Holesail Secure SSH Setup ---"
echo "Note: Keys must NOT contain characters: 0, 1, 8, 9, l, v"
read -p "Enter Secret Key (Leave blank to auto-generate): " USER_KEY

# Z32 Alphabet (Standard used by Holesail/Hypercore)
Z32_SAFE="ybndrfszgctmqpkhxwjica34567"

if [ -z "$USER_KEY" ]; then
    # Auto-generate
    HOLESAIL_KEY=$(LC_ALL=C tr -dc "$Z32_SAFE" < /dev/urandom | head -c 32)
    echo "Generated Key: $HOLESAIL_KEY"
else
    # Manual Key Validation: Check for forbidden characters
    if [[ "$USER_KEY" =~ [0189lvLV] ]]; then
        echo "ERROR: Your manual key contains invalid characters (0, 1, 8, 9, l, or v)."
        echo "Please run the script again with a valid key."
        exit 1
    fi
    HOLESAIL_KEY=$USER_KEY
fi

read -p "Enter SSH Port (default 22): " SSH_PORT
SSH_PORT=${SSH_PORT:-22}

# 3. Create the systemd service file
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

# 4. Activation
sudo systemctl daemon-reload
sudo systemctl enable holesail.service
sudo systemctl start holesail.service

echo "-----------------------------------------------"
echo "SERVICE STARTED SUCCESSFULLY"
echo "Your Key: $HOLESAIL_KEY"
echo "-----------------------------------------------"
echo "Connect from your client using:"
echo "holesail $HOLESAIL_KEY --port 2222"