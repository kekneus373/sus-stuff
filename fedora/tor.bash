#!/usr/bin/env bash

# Re-run the script as root if not already running as root
if [ "$EUID" -ne 0 ]; then
  echo "This script requires root. Re-running with sudo..."
  exec sudo "$0" "$@"
fi

echo "Starting TOR..."
systemctl start tor.service
systemctl status tor.service --no-pager

printf "\n"
echo ">>> Done. Now, Enable SOCKS5 proxy in Falkon (127.0.0.1:9050)! <<<"
