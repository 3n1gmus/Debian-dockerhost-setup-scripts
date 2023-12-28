#!/bin/bash

# Set your variables
local_directory="/path/to/your/local/directory"
remote_user="your_remote_user"
remote_host="your_remote_host"
remote_directory="/path/to/your/remote/directory"

# Rsync command to sync remote to local
rsync -avz -e ssh "$remote_user@$remote_host:$remote_directory" "$local_directory"