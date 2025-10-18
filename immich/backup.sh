#!/bin/bash
# ===================================================================
# Immich Backup Script (Cron-Ready)
# Compresses and encrypts ~/immich into ~/gdrivebkp with date/time tag
# Uploads to Google Drive and removes previous backup remotely
# ===================================================================

set -euo pipefail

# Make sure GPG runs without TTY (for cron)
export GPG_TTY=$(tty || true)

# Paths
SRC_DIR="/home/joako/immich"
DEST_DIR="/home/joako/gdrivebkp"
PASSPHRASE_FILE="/home/joako/.gpg_pass"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_NAME="immich_backup_${TIMESTAMP}.tar.gz.gpg"
BACKUP_PATH="${DEST_DIR}/${BACKUP_NAME}"

# Create destination directory if not exists
mkdir -p "$DEST_DIR"

echo "🔒 Starting Immich backup..."
echo "Source: $SRC_DIR"
echo "Destination: $BACKUP_PATH"

# Create and encrypt backup (AES256, no prompts)
tar -czf - "$SRC_DIR" | \
gpg --batch --yes --passphrase-file "$PASSPHRASE_FILE" \
    --symmetric --cipher-algo AES256 -o "$BACKUP_PATH"

# Verify success
if [ -f "$BACKUP_PATH" ]; then
    echo "✅ Backup completed successfully: $BACKUP_PATH"
else
    echo "❌ Backup failed!"
    exit 1
fi

# Get previous backup (second newest)
LAST_BKP=$(ls -1t "${DEST_DIR}"/immich_backup_*.tar.gz.gpg | sed -n 2p || true)

echo "🆕 Current backup: $(basename "$BACKUP_PATH")"
if [ -n "$LAST_BKP" ]; then
    LAST_BKP_NAME=$(basename "$LAST_BKP")
    echo "📁 Previous backup: $LAST_BKP_NAME"
else
    echo "ℹ️ No previous local backup found."
    LAST_BKP_NAME=""
fi

# Upload new backup to Google Drive
echo "☁️ Uploading new backup to Google Drive..."
rclone copy "$BACKUP_PATH" "GoogleDrive:/Linux_bkps/" --progress

# Remove previous backup from Google Drive if it exists
if [ -n "$LAST_BKP_NAME" ]; then
    echo "🧹 Removing previous backup from Google Drive: $LAST_BKP_NAME"
    rclone delete "GoogleDrive:/Linux_bkps/$LAST_BKP_NAME" || true
fi

# Delete local backups older than 7 days
find "$DEST_DIR" -name "immich_backup_*.tar.gz.gpg" -mtime +7 -delete

echo "✅ Backup process finished successfully."
