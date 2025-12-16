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

# set -a (enable automatic export): Automatically export all variables that are created or modified from now on
# set +a (disable automatic export): turns off the automatic export behavior, returning to normal shell behavior
# where you need explicit export commands.


# Subdomains to add
SUBDOMAINS=(
    "$DOMAIN_NAME"
    "static.$DOMAIN_NAME"
    "adminer.$DOMAIN_NAME"
    "portainer.$DOMAIN_NAME"
)

echo "Setting up /etc/hosts entries for domain: $DOMAIN_NAME"

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "This script requires sudo privileges to modify /etc/hosts"
    exit 1
fi

# Backup current hosts file
cp "$HOSTS_FILE" "${HOSTS_FILE}.backup"

# Remove old entries for this domain (cleanup)
grep -v "$DOMAIN_NAME" "$HOSTS_FILE" > "$TEMP_FILE" || true

# Add new entries
for subdomain in "${SUBDOMAINS[@]}"; do
    echo "127.0.0.1    $subdomain" >> "$TEMP_FILE"
    echo "Added: 127.0.0.1    $subdomain"
done

# Replace hosts file
mv "$TEMP_FILE" "$HOSTS_FILE"

echo "/etc/hosts updated successfully!"
echo "Backup saved at ${HOSTS_FILE}.backup"