# 1. Stop the running service
sudo systemctl stop holesail.service

# 2. Disable it so it doesn't start on boot
sudo systemctl disable holesail.service

# 3. Remove the service file itself
sudo rm /etc/systemd/system/holesail.service

# 4. Tell systemd to forget the service existed
sudo systemctl daemon-reload

# 5. Reset the failed/status state (optional)
sudo systemctl reset-failed

echo "Original Holesail service has been completely removed."