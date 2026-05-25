#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

echo "=== Starting Docker Installation with Custom Logging ==="

# 1. Update package lists
apt-get update

# 2. Create required directories (including Docker's config directory)
mkdir -p /etc/apt/keyrings
mkdir -p /etc/docker

# 3. Write log rotation settings to /etc/docker/daemon.json
cat <<EOF > /etc/docker/daemon.json
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  }
}
EOF
echo "--> Configured log rotation in /etc/docker/daemon.json"

# 4. Add Docker's official GPG key
curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# 5. Set up the stable repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

# 6. Update package lists with the new repository
apt-get update

# 7. Install ALL prerequisites and Docker packages in a single line
apt-get install -y apt-transport-https ca-certificates curl gnupg software-properties-common cifs-utils nfs-common lsb-release docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# 8. Add the current user to the docker group
if [ "$USER" != "root" ]; then
    usermod -aG docker "$USER"
    echo "--> Added user '$USER' to the docker group."
else
    echo "--> Running as root; skipping docker group assignment."
fi

echo "=== Installation Complete ==="
echo "Docker Version:"
docker --version
echo "Docker Compose Version:"
docker compose version

echo "--------------------------------------------------------"
echo "NOTE: To apply docker group permissions without logging out,"
echo "run the following command in your terminal:"
echo "    newgrp docker"
echo "--------------------------------------------------------"