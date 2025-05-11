#!/bin/bash

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Paths
WORK_DIR="$SCRIPT_DIR/homepage/config"
BACKUP_FILE="$SCRIPT_DIR/homepage_backup.zip"  # Zip file saved next to this script

# Function to zip and encrypt
do_zip() {
    echo "Creating encrypted zip file at $BACKUP_FILE..."
    cd "$WORK_DIR" || exit 1  # Change dir to work_dir so paths are relative
    sudo zip -er "$BACKUP_FILE" .
}

# Function to unzip and decrypt
do_unzip() {
    echo "Extracting zip file..."
    sudo unzip "$BACKUP_FILE" -d "$WORK_DIR"
    if [ $? -eq 0 ]; then
        echo "Extraction successful. Deleting $BACKUP_FILE..."
        sudo rm -f "$BACKUP_FILE"
    else
        echo "Extraction failed. Backup file not deleted."
    fi
}

# Check argument
case "$1" in
    zip) do_zip ;;
    unzip) do_unzip ;;
    *)
        echo "Usage: $0 {zip|unzip}"
        exit 1
        ;;
esac
