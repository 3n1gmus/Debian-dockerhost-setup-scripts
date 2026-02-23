#!/bin/bash

# 1. Ask for configuration details
echo "--- Holesail Service Setup (z32 Fix) ---"
read -p "Enter Secret Key (Leave blank to auto-generate a valid one): " USER_KEY

# 2. Generate key if blank using the z32 alphabet
if [ -z "$USER_KEY" ]; then
    # Z32 alphabet excludes: 0, 1, 8, 9, l, v, etc.
    Z32_ALPHABET="ybndrfszgctmqpkhxwjicalsurotkpey"
    HOLESAIL_KEY=$(LC_ALL=C tr -dc "$Z32_ALPHABET" < /dev/urandom | head -c 32)
    echo "Generated Valid Key: $HOLESAIL_KEY"
else
    HOLESAIL_KEY=$USER_KEY
fi

read -p "Enter SSH Port (default is 22): " SSH_PORT
SSH_PORT=${SSH_PORT:-22}

# 3. Create/Overwrite the service file
SERVICE_FILE="/etc/systemd/system/holesail.service"
sudo bash -c "cat > $SERVICE_FILE" <<EOF
[Unit]
Description=Holesail SSH Tunnel Server
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/holesail --live $SSH_PORT --key $HOLESAIL_KEY
Restart=always
RestartSec=10
User=root

[Install]
WantedBy=multi-user.target
EOF

# 4. Activate
sudo systemctl daemon-reload
sudo systemctl enable holesail.service
sudo systemctl restart holesail.service

echo "-----------------------------------------------"
echo "Holesail is now running with a valid z32 key."
echo "Your New Key: $HOLESAIL_KEY"
echo "To connect: holesail $HOLESAIL_KEY --port 2222"
echo "-----------------------------------------------"