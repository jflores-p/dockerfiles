#!/bin/bash
SRC="/home/joako/gdrivebkp/"
DEST="/mnt/winbackup/pi_backups/"
LOG="/var/log/pi_to_pc_backup.log"

# Only run if share is available
if mountpoint -q /mnt/winbackup; then
    rsync -avh --delete --progress "$SRC" "$DEST" >> "$LOG" 2>&1
fi

