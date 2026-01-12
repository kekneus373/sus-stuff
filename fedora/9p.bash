#!/usr/bin/env bash

# Re-run the script as root if not already running as root
if [ "$EUID" -ne 0 ]; then
  echo "This script requires root. Re-running with sudo..."
  exec sudo "$0" "$@"
fi

tag="/mnt/sh"
mount="/mnt/sh"

mount -t 9p -o trans=virtio,mount_tag="$tag",rw,users "$tag" "$mount"
