#!/usr/bin/env bash

# ---        Arch Linux LXQt as a Daily Distro        ---
# --- QUIRK #1. Restore Locale Settings after Upgrade ---

export rundir="$HOME"/Applications/ArchLXQt
ualoc="$rundir"/01-session.conf
curloc="$HOME"/.config/lxqt/session.conf
date=$(date +'%s')

# ask before activation
read -p "[$(date +'%Y-%m-%d %H:%M:%S')] WARNING!!! You MUST run the script from TTY to restore the settings. Otherwise, the files will be replaced back as soon as you log off LXQt. Continue nonetheless? (y/N): " response

# default to "N"
response=${response:-N}

if [ $response == "y" ] || [ $response == "Y" ]; then
	echo "[$(date +'%Y-%m-%d %H:%M:%S')] Backing up current configuration..."
	mv "$curloc" "$curloc"-"$date".bak
	echo "[$(date +'%Y-%m-%d %H:%M:%S')] Restoring uk-UA locale settings..."
	cp "$ualoc" "$curloc"
else
	exit 1
fi

# suggest to log out
read -p "[$(date +'%Y-%m-%d %H:%M:%S')] Wanna Log Out now? (Y/n): " leave

# default to "Y"
leave=${leave:-Y}

if [ $leave == "y" ] || [ $leave == "Y" ]; then
	exit && logout
else
	exit 1
fi
