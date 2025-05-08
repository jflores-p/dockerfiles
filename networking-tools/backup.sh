#!/bin/bash

# Set the path to work_dir
WORK_DIR="proxy-manager"
BACKUP_FILE="npm_backup.zip"

# Folders to include
FOLDERS=("$WORK_DIR/data" "$WORK_DIR/letsencrypt")

# Function to zip and encrypt
do_zip() {
  echo "Creating encrypted zip file..."
  zip -er "$BACKUP_FILE" "${FOLDERS[@]}"
#  sudo chmod 777 $BACKUP_FILE
}

# Function to unzip and decrypt
do_unzip() {
  echo "Extracting zip file..."
  unzip "$BACKUP_FILE" #-d "$WORK_DIR"
  
  if [ $? -eq 0 ]; then
    echo "Extraction successful. Deleting $BACKUP_FILE..."
    rm -f "$BACKUP_FILE"
  else
    echo "Extraction failed. Backup file not deleted."
  fi
}

# Check argument
case "$1" in
  zip)
    do_zip
    ;;
  unzip)
    do_unzip
    ;;
  *)
    echo "Usage: $0 {zip|unzip}"
    exit 1
    ;;
esac

