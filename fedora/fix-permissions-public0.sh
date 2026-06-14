#!/usr/bin/env bash

# Re-run the script as root if not already running as root
if [ "$EUID" -ne 0 ]; then
        echo "[$(date +'%Y-%m-%d %H:%M:%S')] This script requires root. Re-running with sudo..."
        exec sudo "$0" "$@"
fi

dir="/home/wynz/Public/0"
mask=0755
owner="wynz:users"

echo "--- Script for fixing permissions in "$dir" ---"
echo "[$(date +'%Y-%m-%d %H:%M:%S')] Setting $mask mask for all files recursively in "$dir"..."
chmod -R $mask "$dir"
echo "[$(date +'%Y-%m-%d %H:%M:%S')] Changing OWNER:GROUP to $owner recursively to "$dir"..."
chown -R $owner "$dir"
echo "[$(date +'%Y-%m-%d %H:%M:%S')] Command completed successfully!"

exit 0
