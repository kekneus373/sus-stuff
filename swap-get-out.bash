#!/usr/bin/env bash

# Re-run the script as root if not already running as root
if [ "$EUID" -ne 0 ]; then
  echo "This script requires root. Re-running with sudo..."
  exec sudo "$0" "$@"
fi

free_mem="$(free | grep 'Mem:' | awk '{print $7}')"
used_swap="$(free | grep 'Swap:' | awk '{print $3}')"

echo -e "Free memory:\t$free_mem kB ($((free_mem / 1024)) MiB)\nUsed swap:\t$used_swap kB ($((used_swap / 1024)) MiB)"
if [[ $used_swap -eq 0 ]]; then
    echo "Congratulations! No swap is in use."
elif [[ $used_swap -lt $free_mem ]]; then
    echo "Freeing swap..."
    swapoff -a
    swapon -a
else
    echo "Not enough free memory. Exiting."
    exit 1
fi
