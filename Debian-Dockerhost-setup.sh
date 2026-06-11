#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Ensure the script is run with root privileges
if [ "$EUID" -ne 0 ]; then
    echo "Error: Please run this script as root or with sudo."
    exit 1

fi

echo "=== Starting Docker Installation with Custom Logging (DEB822) ==="

# 1. Update package lists and install initial prerequisites
echo "--> Updating package lists and installing basic tools..."
apt-get update
apt-get install -y curl gnupg

# 2. Create required directories (including Docker's config directory)
mkdir -p /etc/apt/sources.list.d
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

# 4. Fetch the GPG key and format the repository into DEB822 format
# This sources /etc/os-release to dynamically grab the correct Debian version name
. /etc/os-release

echo "--> Configuring Docker DEB822 repository..."
cat <<EOF > /etc/apt/sources.list.d/docker.sources
Types: deb
URIs: https://download.docker.com/linux/debian
Suites: ${VERSION_CODENAME}
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By:
 $(curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor | base64 | tr -d '\n')
EOF

# 5. Update package lists with the new DEB822 repository
echo "--> Updating package lists with Docker repository..."
apt-get update

# 6. Install ALL prerequisites and Docker packages
echo "--> Installing Docker and storage utilities..."
apt-get install -y \
  apt-transport-https \
  ca-certificates \
  cifs-utils \
  nfs-common \
  docker-ce \
  docker-ce-cli \
  containerd.io \
  docker-buildx-plugin \
  docker-compose-plugin

# 7. Add the non-root user who called sudo to the docker group
if [ -n "$SUDO_USER" ] && [ "$SUDO_USER" != "root" ]; then
    usermod -aG docker "$SUDO_USER"
    echo "--> Added user '$SUDO_USER' to the docker group."
else
    echo "--> Running as inherent root; skipping docker group assignment."
fi

echo "=== Installation Complete ==="
echo "Docker Version:"
docker --version
echo "Docker Compose Version:"
docker compose version

echo "--------------------------------------------------------"
if [ -n "$SUDO_USER" ] && [ "$SUDO_USER" != "root" ]; then
    echo "NOTE: To apply docker group permissions without logging out,"
    echo "run the following command in your terminal as your normal user:"
    echo "    newgrp docker"
fi
echo "--------------------------------------------------------"