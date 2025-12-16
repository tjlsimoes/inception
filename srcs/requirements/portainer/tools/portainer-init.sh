#!/bin/bash
set -e

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