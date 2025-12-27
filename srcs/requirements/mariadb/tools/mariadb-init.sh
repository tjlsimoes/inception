#!/bin/bash
# Exit immediately if a command exits with a non-zero status
set -e
# Define the data directory where MariaDB stores its databases
DATA_DIR="/var/lib/mysql"

echo "Starting MariaDB setup..."

# Helper function to load value from _FILE if present
load_if_file() {
    local var_name="$1"
    local file_var="${var_name}_FILE"
    if [ -n "${!file_var:-}" ] && [ -f "${!file_var}" ]; then
        # Read file, trim whitespace/newlines
        export "$var_name"=$(cat "${!file_var}" | tr -d '\r\n\t ')
        echo "Loaded $var_name from file secret."
    fi
}

# ${!file_var:-} → The :- part means: if the variable is unset or empty, substitute an empty string (so [ -n ... ] will be false).
# [ -n "${!file_var:-}" ] → Checks whether the _FILE variable is set and non-empty.
# [ -f "${!file_var}" ] → Checks whether the path stored in that variable actually points to an existing regular file.

# Load secrets from files if _FILE env vars are set
load_if_file "MYSQL_ROOT_PASSWORD"
load_if_file "MYSQL_PASSWORD"
load_if_file "MYSQL_DATABASE"
load_if_file "MYSQL_USER"

if [ -z "$MYSQL_ROOT_PASSWORD" ]; then
    echo "ERROR: MYSQL_ROOT_PASSWORD is not set!"
    exit 1
fi
if [ -z "$MYSQL_DATABASE" ]; then
    echo "ERROR: MYSQL_DATABASE is not set!"
    exit 1
fi
if [ -z "$MYSQL_USER" ]; then
    echo "ERROR: MYSQL_USER is not set!"
    exit 1
fi
if [ -z "$MYSQL_PASSWORD" ]; then
    echo "ERROR: MYSQL_PASSWORD is not set!"
    exit 1
fi

echo "Environment variables verified:"
echo " MYSQL_DATABASE: $MYSQL_DATABASE"
echo " MYSQL_USER: $MYSQL_USER"
# Check if we need to initialize the data directory
if [ ! -d "$DATA_DIR/mysql" ]; then
    echo "Initializing MariaDB data directory..."
    mysql_install_db --user=mysql --datadir="$DATA_DIR"
    echo "MariaDB data directory initialized."
else
echo "MariaDB system database exists - skipping data directory initialization."
fi
# Idempotent init SQL file 
INIT_FILE="/tmp/mariadb-init.sql"
cat > "$INIT_FILE" <<-EOSQL
    -- Delete anonymous users for security (idempotent: no-op if none exist)
    DELETE FROM mysql.user WHERE User='';
    -- Delete remote root login for security (idempotent)
    DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
    -- Set root password (idempotent: sets to current env value every time, assuming env consistency)
    ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
    -- Create the WordPress database (idempotent)
    CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
    -- Create the WordPress admin user with full privileges (idempotent)
    CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
    GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%' WITH GRANT OPTION;
    -- Apply all privilege changes (idempotent)
    FLUSH PRIVILEGES;
EOSQL

echo "Starting MariaDB server..."
exec mariadbd --user=mysql --datadir="$DATA_DIR" --bind-address=0.0.0.0 --skip-networking=0 --init-file="$INIT_FILE"