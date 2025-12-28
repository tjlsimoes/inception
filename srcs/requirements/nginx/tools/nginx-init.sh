#!/bin/bash
set -e

load_if_file() {
    local var_name="$1"
    local file_var="${var_name}_FILE"

    if [ -n "${!file_var:-}" ] && [ -f "${!file_var}" ]; then
        export "$var_name"=$(cat "${!file_var}" | tr -d '\r\n\t ')
        echo "Loaded $var_name from secret file."
    fi
}

echo "Loading configuration from environment and/or secrets..."

# Load ALL variables that support _FILE
load_if_file "DOMAIN_NAME"

# Optional: custom wait timeout
TIMEOUT=${WAIT_TIMEOUT:-60}  # seconds
INTERVAL=2                    # seconds per check
ELAPSED=0

echo "Waiting for WordPress to become available at wordpress:9000..."

# Loop until curl succeeds or timeout is reached
while ! bash -c "echo > /dev/tcp/wordpress/9000" 2>/dev/null; do
    if [ "$ELAPSED" -ge "$TIMEOUT" ]; then
        echo "ERROR: WordPress not reachable after $TIMEOUT seconds."
        exit 1
    fi
    sleep $INTERVAL
    ELAPSED=$((ELAPSED + INTERVAL))
done

echo "WordPress is up! Starting NGINX..."

# Start NGINX in foreground (PID 1)
exec nginx -g "daemon off;"
