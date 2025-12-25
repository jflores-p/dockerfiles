#!/bin/bash

# Paths
BACKUP_SCRIPT="/home/joako/dockerfiles/pi_to_pc_backup.sh"
LAST_RUN_FILE="/home/joako/dockerfiles/bkp_logs/last_backup_run.log"
LOG="/home/joako/dockerfiles/bkp_logs/pi_auto_trigger.log"
DESKTOP_IP="10.10.1.199"   # <-- Replace with your desktop’s IP or hostname

# --- Check if desktop is reachable ---
if ping -c 1 -W 2 "$DESKTOP_IP" > /dev/null 2>&1; then
    echo "$(date): Desktop reachable." >> "$LOG"

    TODAY=$(date +%Y-%m-%d)
    LAST_RUN_DATE=$(cat "$LAST_RUN_FILE" 2>/dev/null)

    if [[ "$TODAY" != "$LAST_RUN_DATE" ]]; then
        echo "$(date): First connection today. Starting backup..." >> "$LOG"
        
        # Run backup script (using nohup so it continues independently)
        nohup sudo bash "$BACKUP_SCRIPT" >> "$LOG" 2>&1 &
        
        # Mark today's run
        echo "$TODAY" > "$LAST_RUN_FILE"
    else
        echo "$(date): Backup already run today. Skipping." >> "$LOG"
    fi
else
    echo "$(date): Desktop not reachable." >> "$LOG"
fi
