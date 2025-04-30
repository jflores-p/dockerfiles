#!/bin/bash

########################################
# 🔐 Manage .env Files: Encrypt, Decrypt, Backup, Restore
#
# Usage:
#   ./manage_env_files.sh -e   # Encrypt all .env files
#   ./manage_env_files.sh -d   # Decrypt all .env.enc files
#   ./manage_env_files.sh -b   # Backup all .env files to tar.gz.enc
#   ./manage_env_files.sh -r   # Restore backup tar.gz.enc
#
# List of .env file paths must be in 'env_files.txt' (one per line).
# Paths in env_files.txt can be relative — they are resolved relative to env_files.txt itself.
########################################

# Resolve the directory where env_files.txt is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_LIST_FILE="$SCRIPT_DIR/env_files.txt"

# Check argument
if [[ "$1" != "-e" && "$1" != "-d" && "$1" != "-b" && "$1" != "-r" ]]; then
  echo "❌ Invalid argument!"
  echo "Usage:"
  echo "  $0 -e   # Encrypt"
  echo "  $0 -d   # Decrypt"
  echo "  $0 -b   # Backup"
  echo "  $0 -r   # Restore"
  exit 1
fi

# Get password
read -s -p "Enter password: " PASSWORD
echo

# Check if env list file exists (except for restore)
if [[ "$1" != "-r" && ! -f "$ENV_LIST_FILE" ]]; then
  echo "❌ File $ENV_LIST_FILE not found!"
  exit 1
fi

# Backup mode
if [ "$1" == "-b" ]; then
  TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
  BACKUP_TAR="$SCRIPT_DIR/env_backup_$TIMESTAMP.tar.gz"
  BACKUP_ENC="$BACKUP_TAR.enc"

  FILES_TO_BACKUP=()

  while IFS= read -r REL_ENV_PATH; do
    [ -z "$REL_ENV_PATH" ] && continue
    ENV_PATH="$SCRIPT_DIR/$REL_ENV_PATH"
    if [ -f "$ENV_PATH" ]; then
      FILES_TO_BACKUP+=("$ENV_PATH")
      echo "📦 Added to backup: $REL_ENV_PATH"
    else
      echo "⚠️  Skipping: $REL_ENV_PATH (file not found)"
    fi
  done < "$ENV_LIST_FILE"

  if [ ${#FILES_TO_BACKUP[@]} -eq 0 ]; then
    echo "❌ No valid .env files found to backup."
    exit 1
  fi

  # Create tar.gz
  tar -czf "$BACKUP_TAR" -C "$SCRIPT_DIR" "${FILES_TO_BACKUP[@]#$SCRIPT_DIR/}"
  echo "✅ Created archive: $(basename "$BACKUP_TAR")"

  # Encrypt archive with PBKDF2
  openssl enc -aes-256-cbc -pbkdf2 -iter 100000 -salt -in "$BACKUP_TAR" -out "$BACKUP_ENC" -pass pass:"$PASSWORD"
  echo "🔐 Encrypted backup: $(basename "$BACKUP_ENC")"

  rm "$BACKUP_TAR"
  echo "🗑️  Removed unencrypted archive"

  echo "🎉 Backup done!"
  exit 0
fi

# Restore mode
if [ "$1" == "-r" ]; then
  # Find the latest backup file
  LATEST_BACKUP=$(ls -t "$SCRIPT_DIR"/env_backup_*.tar.gz.enc 2>/dev/null | head -n1)

  if [ -z "$LATEST_BACKUP" ]; then
    echo "❌ No backup .enc file found in $SCRIPT_DIR"
    exit 1
  fi

  RESTORE_TAR="${LATEST_BACKUP%.enc}"  # Remove .enc extension

  # Decrypt
  openssl enc -d -aes-256-cbc -pbkdf2 -iter 100000 -in "$LATEST_BACKUP" -out "$RESTORE_TAR" -pass pass:"$PASSWORD"
  echo "🔓 Decrypted backup archive: $(basename "$RESTORE_TAR")"

  # Extract
  tar -xzf "$RESTORE_TAR" -C "$SCRIPT_DIR"
  echo "📂 Extracted files to: $SCRIPT_DIR"

  # Optionally delete the decrypted archive
  rm "$RESTORE_TAR"
  echo "🗑️  Removed decrypted archive"

  echo "🎉 Restore done!"
  exit 0
fi

# Encrypt / Decrypt modes
while IFS= read -r REL_ENV_PATH; do
  [ -z "$REL_ENV_PATH" ] && continue
  ENV_PATH="$SCRIPT_DIR/$REL_ENV_PATH"

  if [ "$1" == "-e" ]; then
    if [ ! -f "$ENV_PATH" ]; then
      echo "⚠️  Skipping: $ENV_PATH (file not found)"
      continue
    fi
    ENC_FILE="${ENV_PATH}.enc"
    openssl enc -aes-256-cbc -pbkdf2 -iter 100000 -salt -in "$ENV_PATH" -out "$ENC_FILE" -pass pass:"$PASSWORD"
    echo "✅ Encrypted: $REL_ENV_PATH → $(basename "$ENC_FILE")"

  elif [ "$1" == "-d" ]; then
    ENC_FILE="${ENV_PATH}.enc"
    if [ ! -f "$ENC_FILE" ]; then
      echo "⚠️  Skipping: $REL_ENV_PATH.enc (encrypted file not found)"
      continue
    fi
    openssl enc -d -aes-256-cbc -pbkdf2 -iter 100000 -in "$ENC_FILE" -out "$ENV_PATH" -pass pass:"$PASSWORD"
    echo "🔓 Decrypted: $REL_ENV_PATH.enc → $(basename "$ENV_PATH")"
  fi

done < "$ENV_LIST_FILE"

echo "🎉 Done!"
