#!/usr/bin/env bash

# ---   Arch Linux LXQt as a Daily Distro  ---
# --- #2: Xprinter Label Printer Installer ---

# -------------------------------------------------
# Configuration – adjust these variables as needed
# -------------------------------------------------

echo "--- Xprinter POS Printer Driver Installer for non-Debian systems ---"

# must be run as root ^^^^

# Path to the .deb package you want to unpack
echo "Path to .deb driver package: "
read DEB_FILE

# Temporary directory where the .deb will be expanded
TMP_DIR="/tmp/xprint"

# Destination directories for CUPS components
# (replace with the actual locations on your system)
CUPS_DRIVER_DIR="/usr/share/cups/model/xprinter"
mkdir -p "$CUPS_DRIVER_DIR"
CUPS_FILTER_DIR="/usr/lib/cups/filter"

# -------------------------------------------------
# Helper function – prints a message to stderr
# -------------------------------------------------
log() {
    echo "[*] $*" >&2
}

# -------------------------------------------------
# Main workflow
# -------------------------------------------------

# Prepare for extraction
if [[ -d "$TMP_DIR" ]]; then
    log "[$(date +'%Y-%m-%d %H:%M:%S')] Removing old temporary directory: $TMP_DIR"
    rm -rf "$TMP_DIR"
fi

log "[$(date +'%Y-%m-%d %H:%M:%S')] Creating temporary directory: $TMP_DIR"
mkdir -p "$TMP_DIR"
cd "$TMP_DIR"

# Unpack the .deb file
log "[$(date +'%Y-%m-%d %H:%M:%S')] Extracting $DEB_FILE ..."
# A .deb is an ar archive containing control.tar.* and data.tar.*
# We only need the data.tar.* part (the actual files)
ar x "$DEB_FILE" data.tar.*  # creates data.tar.xz / data.tar.gz / data.tar.bz2 ..

# Determine compression type and extract accordingly
DATA_TAR=$(ls data.tar.*)
case "$DATA_TAR" in
    *.xz)  tar -xJf "$DATA_TAR" -C "$TMP_DIR" ;;
    *.gz)  tar -xzf "$DATA_TAR" -C "$TMP_DIR" ;;
    *.bz2) tar -xjf "$DATA_TAR" -C "$TMP_DIR" ;;
    *)     log "[$(date +'%Y-%m-%d %H:%M:%S')] Unexpected compression for $DATA_TAR"; exit 1 ;;
esac

# ------------------------------------------------------------------
# Find the printer driver files (usually *.ppd, *.drv, *.so, etc.)
# Adjust the find patterns if your drivers have different extensions.
# ------------------------------------------------------------------
log "[$(date +'%Y-%m-%d %H:%M:%S')] Locating printer driver files ..."
DRIVER_FILES=$(find "$TMP_DIR" -type f $$ -name "*.ppd" $$)

# ------------------------------------------------------------------
# Find the rastertosnailep binary (or script)
# ------------------------------------------------------------------
log "[$(date +'%Y-%m-%d %H:%M:%S')] Locating rastertosnailep ..."
RASTERTO_SNAILEP=$(find "$TMP_DIR" -type f -name "rastertosnailep-x64")

# ------------------------------------------------------------------
# Copy the found files to the appropriate CUPS directories
# ------------------------------------------------------------------
if [[ -n "$DRIVER_FILES" ]]; then
    log "[$(date +'%Y-%m-%d %H:%M:%S')] Copying driver files to $CUPS_DRIVER_DIR ..."
    for file in $DRIVER_FILES; do
        cp -v "$file" "$CUPS_DRIVER_DIR/"
    done
else
    log "[$(date +'%Y-%m-%d %H:%M:%S')] No driver files were found."
fi

if [[ -n "$RASTERTO_SNAILEP" ]]; then
    log "[$(date +'%Y-%m-%d %H:%M:%S')] Copying rastertosnailep to $CUPS_FILTER_DIR ..."
    cp -v "$RASTERTO_SNAILEP" "$CUPS_FILTER_DIR/rastertosnailep-xprinter"
else
    log "[$(date +'%Y-%m-%d %H:%M:%S')] rastertosnailep was not found."
fi

# Post-install tasks
systemctl restart cups
rm -rf "$TMP_DIR"

# Ask to open the CUPS web portal
read -p "[$(date +'%Y-%m-%d %H:%M:%S')] Wanna configure the printer now? (Y/n): " cups

# default to "Y"
cups=${cups:-Y}

if [ $cups == "y" ] || [ $cups == "Y" ]; then
        echo "[$(date +'%Y-%m-%d %H:%M:%S')] Opening the CUPS control panel ..."
        xdg-open "http://localhost:631" &&
        exit
else
        exit 1
fi

log "[$(date +'%Y-%m-%d %H:%M:%S')] Finished. Remember to restart CUPS when needed"

