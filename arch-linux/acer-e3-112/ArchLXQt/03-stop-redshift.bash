#!/usr/bin/env bash

# ---        Arch Linux LXQt as a Daily Distro        ---
# --- QUIRK #2. Stop Redshift GTK while in TUI screen ---

date=$(date +'%s')

echo "$date Stopping the unit..."
systemctl --user stop redshift-gtk.service
systemctl --user status redshift-gtk --no-pager
echo "$date Done!"
