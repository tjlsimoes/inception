#!/bin/bash

# Get the project root directory (2 levels up from srcs/tools/)
PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ENV_FILE="$PROJECT_ROOT/.env"

# Check if .env exists
if [ ! -f "$ENV_FILE" ]; then
    echo "Error: .env file not found at $ENV_FILE"
    exit 1
fi

# Source the .env file
set -a
source "$ENV_FILE"
set +a

echo "Removing $DOMAIN_NAME entries from /etc/hosts..."

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "This script requires sudo privileges to modify /etc/hosts"
    exit 1
fi

# Backup current hosts file
cp "$HOSTS_FILE" "${HOSTS_FILE}.backup"

# Remove entries for this domain
grep -v "$DOMAIN_NAME" "$HOSTS_FILE" > "$TEMP_FILE" || true
mv "$TEMP_FILE" "$HOSTS_FILE"

echo "Cleanup complete! Removed all entries for $DOMAIN_NAME"