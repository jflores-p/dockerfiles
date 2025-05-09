#!/bin/bash

# Check if IP was provided
if [ -z "$1" ]; then
  echo "Usage: $0 <IP_ADDRESS>"
  exit 1
fi

# Get IP from the first argument
IP="$1"
DOMAIN="joakolabs.com"

# Get directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Define your subdomains
SUBDOMAINS=(
 "pihole"
 "portainer"
 "paperless"
 "npm"
 "wireguard"
 "ntopng"
 "vnstat"
 "grafana"
 "composerize"
 "ha"
 "snippets"
)

# Temp output file (inside script dir)
OUTPUT="$SCRIPT_DIR/generated_dnsmasq.conf"

# Start with a header
echo "# Dynamic dnsmasq config generated on $(date)" > "$OUTPUT"

# Loop through subdomains and append in dnsmasq format
for SUB in "${SUBDOMAINS[@]}"; do
  echo "address=/$SUB.$DOMAIN/$IP" >> "$OUTPUT"
done

echo "dnsmasq config generated: $OUTPUT"

# Move to Pi-hole dnsmasq directory with the name '99-custom.conf'
TARGET_DIR="$SCRIPT_DIR/pihole/dnsmasq"
TARGET_FILE="$TARGET_DIR/joakolabs-custom.conf"

# Make sure the target directory exists
mkdir -p "$TARGET_DIR"

# Move (overwrite) the file
mv "$OUTPUT" "$TARGET_FILE"

echo "Moved dnsmasq config to: $TARGET_FILE"

# 🔥 Clean up any leftover generated file just in case
[ -f "$OUTPUT" ] && rm "$OUTPUT" && echo "Cleaned up temp file: $OUTPUT"
