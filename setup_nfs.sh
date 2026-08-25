#!/usr/bin/env bash
set -euo pipefail

CONFIG_FILE="${1:-nfs_mounts.conf}"

# Ensure running as root
if [[ $EUID -ne 0 ]]; then
   echo "Error: This script must be run as root (use sudo)." >&2
   exit 1
fi

# Ensure config file exists
if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "Error: Configuration file '$CONFIG_FILE' not found." >&2
    exit 1
fi

# Install nfs-common if not installed (Debian/Ubuntu focus; adjust for RHEL/CentOS)
if ! command -v mount.nfs &> /dev/null; then
    echo "Installing NFS client packages..."
    apt-get update -qq && apt-get install -y -qq nfs-common
fi

# Parse BASE_DIR from config file and strip quotes/spaces
BASE_DIR=$(grep -E '^BASE_DIR=' "$CONFIG_FILE" | cut -d'=' -f2 | xargs)

if [[ -z "$BASE_DIR" ]]; then
    echo "Error: BASE_DIR is not defined in $CONFIG_FILE" >&2
    exit 1
fi

# Create BASE_DIR if it doesn't exist
mkdir -p "$BASE_DIR"

# Parse NFS export lines (ignore comments and empty lines)
grep -v -E '^\s*#|^\s*$' "$CONFIG_FILE" | grep -v '^BASE_DIR=' | while read -r NFS_EXPORT; do
    # Extract terminating folder name (e.g., /volume1/documents -> documents)
    FOLDER_NAME=$(basename "$NFS_EXPORT")
    MOUNT_POINT="${BASE_DIR}/${FOLDER_NAME}"

    echo "----------------------------------------"
    echo "Processing: $NFS_EXPORT"
    echo "Target:     $MOUNT_POINT"

    # 1. Create local mount directory
    mkdir -p "$MOUNT_POINT"

    # 2. Add to /etc/fstab if not already present
    FSTAB_ENTRY="${NFS_EXPORT} ${MOUNT_POINT} nfs defaults,_netdev 0 0"
    
    if grep -qsF "$MOUNT_POINT" /etc/fstab; then
        echo "--> Notice: Entry for $MOUNT_POINT already exists in /etc/fstab. Skipping fstab update."
    else
        echo "--> Adding entry to /etc/fstab..."
        echo "$FSTAB_ENTRY" >> /etc/fstab
    fi

    # 3. Mount the directory
    if mountpoint -q "$MOUNT_POINT"; then
        echo "--> Notice: $MOUNT_POINT is already mounted."
    else
        echo "--> Mounting $NFS_EXPORT to $MOUNT_POINT..."
        mount "$MOUNT_POINT" && echo "--> Mount successful."
    fi
done

echo "----------------------------------------"
echo "All NFS setup tasks completed!"