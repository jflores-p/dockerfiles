#!/bin/bash
# ===================================================================
# Unified Backup Script (Dynamic Home)
# Supports:
#   ./backup.sh homepage zip
#   ./backup.sh homepage unzip
#   ./backup.sh paperless
#   ./backup.sh immich
#   ./backup.sh proxy zip
#   ./backup.sh proxy unzip
#   ./backup.sh karakeep zip
#   ./backup.sh karakeep unzip
# ===================================================================

set -euo pipefail

# --- Universal Home Directory Resolver ---
# Works with sudo, root cron, or normal user
HOME_DIR=$(getent passwd ${SUDO_USER:-$LOGNAME} | cut -d: -f6 2>/dev/null || echo "$HOME")

# --- Common Settings ---
GPG_PASS="$HOME_DIR/.gpg_pass"
BACKUP_ROOT="$HOME_DIR/bkps"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DATE=$(date +"%Y%m%d")

mkdir -p "$BACKUP_ROOT"

# ===================================================================
# Homepage backup (TAR.GZ + AES encryption)
# ===================================================================
do_homepage_zip() {
    WORK_DIR="$SCRIPT_DIR/misc/homepage/config"
    BACKUP_FILE="$BACKUP_ROOT/homepage_backup_${DATE}.tar.gz.gpg"

    echo "🔒 Creating encrypted homepage backup at $BACKUP_FILE..."
    cd "$WORK_DIR" || exit 1
    tar -czf - . | gpg --batch --yes --symmetric --cipher-algo AES256 \
        --passphrase-file "$GPG_PASS" -o "$BACKUP_FILE"
    echo "✅ Homepage backup complete."
    # Keep only the 2 most recent Homepage backups
    ls -t "$BACKUP_ROOT"/homepage_backup_*.tar.gz.gpg 2>/dev/null | tail -n +3 | xargs -r rm --
}

do_homepage_unzip() {
    WORK_DIR="$SCRIPT_DIR/misc/homepage/config"
    BACKUP_FILE=$(ls -t "$BACKUP_ROOT"/homepage_backup_*.tar.gz.gpg | head -n 1)

    if [ ! -f "$BACKUP_FILE" ]; then
        echo "❌ No homepage backup found."
        exit 1
    fi

    echo "🔓 Decrypting and extracting homepage backup..."
    mkdir -p "$WORK_DIR"
    gpg --batch --yes --decrypt --passphrase-file "$GPG_PASS" "$BACKUP_FILE" | \
        tar -xzf - -C "$WORK_DIR"
    echo "✅ Homepage restore complete."
}

# ===================================================================
# Paperless backup (tar + GPG encryption)
# ===================================================================
do_paperless() {
    SRC_BASE="$HOME_DIR/dockerfiles/misc/paperless"
    DEST_DIR="$BACKUP_ROOT"
    BACKUP_PATH="$DEST_DIR/paperless_backup_${DATE}.tar.gz.gpg"

    echo "🔒 Starting Paperless backup..."
    echo "Destination: $BACKUP_PATH"
    echo "Included directories:"
    for d in data media redisdata; do
        echo "  - $SRC_BASE/$d"
    done

    sudo tar -czf - -C "$SRC_BASE" data media redisdata | \
        gpg --batch --yes --symmetric --cipher-algo AES256 \
        --passphrase-file "$GPG_PASS" -o "$BACKUP_PATH"

    echo "✅ Paperless backup completed: $BACKUP_PATH"
    find "$DEST_DIR" -name "paperless_backup_*.tar.gz.gpg" -mtime +7 -delete
}

# ===================================================================
# Immich backup (tar + GPG encryption)
# ===================================================================
do_immich() {
    SRC_DIR="$HOME_DIR/immich"
    DEST_DIR="$BACKUP_ROOT"
    TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
    BACKUP_PATH="${DEST_DIR}/immich_backup_${TIMESTAMP}.tar.gz.gpg"

    echo "🔒 Starting Immich backup..."
    echo "Source: $SRC_DIR"
    echo "Destination: $BACKUP_PATH"

    tar -czf - "$SRC_DIR" | gpg --batch --yes --symmetric --cipher-algo AES256 \
        --passphrase-file "$GPG_PASS" -o "$BACKUP_PATH"

    echo "✅ Immich backup completed: $BACKUP_PATH"
    # Keep only the 2 most recent Immich backups
    ls -t "$DEST_DIR"/immich_backup_*.tar.gz.gpg 2>/dev/null | tail -n +3 | xargs -r rm --
}

# ===================================================================
# Proxy Manager backup (ZIP + AES encryption)
# ===================================================================
do_proxy_zip() {
    PROXY_DIR="$HOME_DIR/dockerfiles/networking/proxy-manager"
    BACKUP_FILE="$BACKUP_ROOT/npm_backup_${DATE}.zip.gpg"

    echo "🔒 Creating encrypted Proxy Manager backup at $BACKUP_FILE..."
    cd "$PROXY_DIR" || exit 1
    sudo zip -r - data letsencrypt | gpg --batch --yes --symmetric \
        --cipher-algo AES256 --passphrase-file "$GPG_PASS" -o "$BACKUP_FILE"
    echo "✅ Proxy Manager backup complete."
}

do_proxy_unzip() {
    PROXY_DIR="$HOME_DIR/dockerfiles/networking/proxy-manager"
    BACKUP_FILE=$(ls -t "$BACKUP_ROOT"/npm_backup_*.zip.gpg | head -n 1)

    if [ ! -f "$BACKUP_FILE" ]; then
        echo "❌ No Proxy Manager backup found."
        exit 1
    fi

    echo "🔓 Decrypting and extracting Proxy Manager backup..."
    gpg --batch --yes --decrypt --passphrase-file "$GPG_PASS" "$BACKUP_FILE" | \
        sudo unzip -o -d "$PROXY_DIR" -
    echo "✅ Proxy Manager restore complete."
    # Keep only the 2 most recent Proxy Manager backups
    ls -t "$BACKUP_ROOT"/npm_backup_*.zip.gpg 2>/dev/null | tail -n +3 | xargs -r rm --
}

# ===================================================================
# Karakeep backup (ZIP + AES encryption)
# ===================================================================
do_karakeep_zip() {
    KARAKEEP_DIR="$SCRIPT_DIR/misc/karakeep"
    BACKUP_FILE="$BACKUP_ROOT/karakeep_backup_${DATE}.zip.gpg"

    echo "🔒 Creating encrypted Karakeep backup at $BACKUP_FILE..."
    cd "$KARAKEEP_DIR" || exit 1
    sudo zip -r - . | gpg --batch --yes --symmetric \
        --cipher-algo AES256 --passphrase-file "$GPG_PASS" -o "$BACKUP_FILE"
    echo "✅ Karakeep backup complete."
    # Keep only the 2 most recent Karakeep backups
    ls -t "$BACKUP_ROOT"/karakeep_backup_*.zip.gpg 2>/dev/null | tail -n +3 | xargs -r rm --
}

do_karakeep_unzip() {
    KARAKEEP_DIR="$SCRIPT_DIR/misc/karakeep"
    BACKUP_FILE=$(ls -t "$BACKUP_ROOT"/karakeep_backup_*.zip.gpg 2>/dev/null | head -n 1)

    if [ ! -f "$BACKUP_FILE" ]; then
        echo "❌ No Karakeep backup found."
        exit 1
    fi

    echo "🔓 Decrypting and extracting Karakeep backup..."
    mkdir -p "$KARAKEEP_DIR"
    gpg --batch --yes --decrypt --passphrase-file "$GPG_PASS" "$BACKUP_FILE" | \
        sudo unzip -o -d "$KARAKEEP_DIR" -
    echo "✅ Karakeep restore complete."
}

# ===================================================================
# Argument handling (safe defaults)
# ===================================================================
ACTION="${1:-}"   # avoids 'unbound variable' if empty
SUBACTION="${2:-}"

case "$ACTION" in
    homepage)
        case "$SUBACTION" in
            zip) do_homepage_zip ;;
            unzip) do_homepage_unzip ;;
            *) echo "Usage: $0 homepage {zip|unzip}" ;;
        esac
        ;;
    paperless)
        do_paperless
        ;;
    immich)
        do_immich
        ;;
    proxy)
        case "$SUBACTION" in
            zip) do_proxy_zip ;;
            unzip) do_proxy_unzip ;;
            *) echo "Usage: $0 proxy {zip|unzip}" ;;
        esac
        ;;
    karakeep)
        case "$SUBACTION" in
            zip) do_karakeep_zip ;;
            unzip) do_karakeep_unzip ;;
            *) echo "Usage: $0 karakeep {zip|unzip}" ;;
        esac
        ;;
    *)
        echo "Usage:"
        echo "  $0 homepage {zip|unzip}"
        echo "  $0 paperless"
        echo "  $0 immich"
        echo "  $0 proxy {zip|unzip}"
        echo "  $0 karakeep {zip|unzip}"
        exit 1
        ;;
esac
