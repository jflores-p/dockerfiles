#!/bin/bash
SRC="/home/joako/bkps/"
DEST="/mnt/winbackup/pi_backups/"
LOG="/home/joako/dockerfiles/bkp_logs/pi_to_pc_backup.log"

echo "=== Backup started at $(date) ===" >> "$LOG"

if mountpoint -q /mnt/winbackup; then
    sudo rsync -avh --delete --progress "$SRC" "$DEST" >> "$LOG" 2>&1
    echo "=== Backup completed successfully at $(date) ===" >> "$LOG"
else
    echo "Share not mounted at $(date), skipping backup." >> "$LOG"
fi

