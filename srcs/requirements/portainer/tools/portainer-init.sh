#!/bin/bash
set -e

load_if_file() {
    local var_name="$1"
    local file_var="${var_name}_FILE"

    if [ -n "${!file_var:-}" ] && [ -f "${!file_var}" ]; then
        # Read and trim whitespace/newlines/tabs/carriage returns
        export "$var_name"=$(cat "${!file_var}" | tr -d '\r\n\t ')
        echo "Loaded $var_name from secret file."
    fi
}

echo "Loading configuration from environment and/or secrets..."

# Load ALL variables that support _FILE
load_if_file "PORTAINER_ADMIN_PASSWORD"

# Create password file if PORTAINER_ADMIN_PASSWORD is set
if [ -n "$PORTAINER_ADMIN_PASSWORD" ]; then
    echo -n "$PORTAINER_ADMIN_PASSWORD" > /tmp/portainer_password
    echo "Admin password file created"
    # Start Portainer with password file
    exec ./portainer --data /data --http-disabled --admin-password-file /tmp/portainer_password
else
    echo "No admin password set, Portainer will require manual setup"
    # Start Portainer without password (manual setup required)
    exec ./portainer --data /data --http-disabled
fi