#!/usr/bin/env bash
# Version 2 - improved output & scan current dir

timestamp=$(date +%Y%m%d-%H%M%S)

# Prompt the user to choose the directory source
read -p "Do you want to scan the current directory? (Y/n): " choice

# Default to "Y" if the user just presses Enter
choice=${choice:-Y}

if [[ "$choice" =~ ^[Yy]$ ]]; then
    # Use current directory
    dir_path=$(pwd)
    echo "Using current directory: $dir_path"
else
    # Prompt for manual directory path
    echo "Enter the directory path to hash: "
    read dir_path

    # Check if the directory exists
    if [ ! -d "$dir_path" ]; then
        echo "[$(date +'%Y-%m-%d %H:%M:%S')] Error: The directory '$dir_path' does not exist."
        exit 1
    fi

    echo "Using provided directory: $dir_path"
fi

# Change to the specified directory
cd "$dir_path" || exit

# Define the output filename
output_file="checksums-$timestamp-sha256.txt"

# Check if the output file already exists
if [ -f "$output_file" ]; then
    read -p "[$(date +'%Y-%m-%d %H:%M:%S')] The file '$output_file' already exists. Overwrite? (y/n): " overwrite
    if [[ "$overwrite" != "y" && "$overwrite" != "Y" ]]; then
        echo "Operation cancelled."
        exit 0
    fi
fi

echo "[$(date +'%Y-%m-%d %H:%M:%S')] Generating SHA256 checksums for all files in '$dir_path'..."

# Find all files (excluding directories) and calculate SHA256 sum
# The output format is: <hash>  <filename>
find . -type f -exec sha256sum {} + > "$output_file"

if [ $? -eq 0 ]; then
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] Success! Checksums saved to '$output_file'."
    echo "You can verify these later using: sha256sum -c $output_file"
else
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] Error occurred while generating checksums."
    exit 1
fi
