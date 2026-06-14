#!/usr/bin/env bash

# Re-run the script as root if not already running as root
if [ "$EUID" -ne 0 ]; then
        echo "[$(date +'%Y-%m-%d %H:%M:%S')] This script requires root. Re-running with sudo..."
        exec sudo "$0" "$@"
fi

tag="/mnt/sh"
mount="/mnt/sh"

echo "--- Script for connecting the shared 9p VirtIO volume ---"
echo ">>> Choose action:"
select profile in "Mount \`$mount\`" "Unmount \`$mount\`"; do
    case $REPLY in
        1) mount -t 9p -o trans=virtio,mount_tag="$tag",rw,users,x-gvfs-show "$tag" "$mount"; break ;;
        2) umount "$tag"; break ;;
        *) echo "[$(date +'%Y-%m-%d %H:%M:%S')] Invalid option." ;;
    esac
done

exit
