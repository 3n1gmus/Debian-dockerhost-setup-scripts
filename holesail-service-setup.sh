#!/bin/bash

# 1. Ask for configuration details
echo "--- Holesail Service Setup ---"
read -p "Enter Secret Key (Leave blank to auto-generate a strong one): " USER_KEY

# 2. Generate key if blank
if [ -z "$USER_KEY" ]; then
    # Generates a 32-character secure alphanumeric string
    HOLESAIL_KEY=$(LC_ALL=C tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 32)
    echo "Generated Random Key: $HOLESAIL_KEY"
    echo "IMPORTANT: Save this key! You need it to connect from your client."
else
    HOLESAIL_KEY=$USER_KEY
fi

read -p "Enter SSH Port (default is 22): " SSH_PORT
SSH_PORT=${SSH_PORT:-22}

# 3. Create the service file
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
sudo systemctl start holesail.service

echo "-----------------------------------------------"
echo "Holesail is now running as a system service."
echo "Your Permanent Key: $HOLESAIL_KEY"
echo "To connect: holesail $HOLESAIL_KEY --port 2222"
echo "-----------------------------------------------"