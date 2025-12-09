#!/bin/bash
# Exit immediately if a command exits with a non-zero status
set -e

# Define the data directory where MariaDB stores its databases
DATA_DIR="/var/lib/mysql"

echo "Starting MariaDB setup..."

# Verify all required environment variables are set
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

if [ -z "$MYSQL_SECONDARY_USER" ]; then
    echo "ERROR: MYSQL_SECONDARY_USER is not set!"
    exit 1
fi

if [ -z "$MYSQL_SECONDARY_USER_PASSWORD" ]; then
    echo "ERROR: MYSQL_SECONDARY_PASSWORD is not set!"
    exit 1
fi

echo "Environment variables verified:"
echo "  MYSQL_DATABASE: $MYSQL_DATABASE"
echo "  MYSQL_USER: $MYSQL_USER"
echo "  MYSQL_SECONDARY_USER: $MYSQL_SECONDARY_USER"

# Check if we need to initialize the database
# We check both if the mysql system database exists AND if our WordPress database exists
NEED_INIT=false

if [ ! -d "$DATA_DIR/mysql" ]; then
    echo "MariaDB system database not found - full initialization needed."
    NEED_INIT=true
fi

if [ "$NEED_INIT" = true ]; then
    echo "Initializing MariaDB data directory..."
    
    # Initialize the MariaDB data directory
    # This creates the system databases (mysql, performance_schema, etc.)
    # --user=mysql: run as the mysql user for proper permissions
    # --datadir: specify where to create the database files
    mysql_install_db --user=mysql --datadir="$DATA_DIR"
    
    echo "MariaDB data directory initialized."
    
    # Start MariaDB temporarily in the background to configure it
    # --user=mysql: run as mysql user
    # --datadir: location of database files
    # --skip-networking: don't open TCP port yet (security during setup)
    # &: run in background
    mariadbd --user=mysql --datadir="$DATA_DIR" --skip-networking &
    
    # Store the process ID so we can stop it later
    MARIADB_PID=$!
    
    echo "Waiting for MariaDB to start..."
    
    # Wait for MariaDB to be ready to accept connections
    # We try to connect until it succeeds
    for i in {1..30}; do
        if mysqladmin ping --silent 2>/dev/null; then
            echo "MariaDB is ready!"
            break
        fi
        echo "Waiting for MariaDB... ($i/30)"
        sleep 1
    done
    
    # Create the WordPress database and users
    echo "Creating WordPress database and users..."
    
    # Execute SQL commands to set up WordPress
    # -u root: connect as root user (no password yet since this is fresh install)
    mysql -u root <<-EOSQL
        -- Delete anonymous users for security
        DELETE FROM mysql.user WHERE User='';
        
        -- Delete remote root login for security
        DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
        
        -- Set root password from environment variable
        ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
        
        -- Create the WordPress database
        CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
        
        -- Create the WordPress admin user with full privileges
        -- This user will be used by WordPress to manage the database
        CREATE USER '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
        GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
        
        -- Create a second user with limited privileges (read/write but not structure changes)
        CREATE USER '${MYSQL_SECONDARY_USER}'@'%' IDENTIFIED BY '${MYSQL_SECONDARY_PASSWORD}';
        GRANT SELECT, INSERT, UPDATE, DELETE ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_SECONDARY_USER}'@'%';
        
        -- Apply all privilege changes
        FLUSH PRIVILEGES;
EOSQL
    
    if [ $? -eq 0 ]; then
        echo "WordPress database and users created successfully!"
    else
        echo "ERROR: Failed to create database and users!"
        exit 1
    fi
    
    # Stop the temporary MariaDB instance
    # We'll start it properly as PID 1 below
    if ! kill -s TERM "$MARIADB_PID" || ! wait "$MARIADB_PID"; then
        echo "MariaDB temporary instance stopped."
    fi
    
    echo "Setup complete!"
else
    echo "MariaDB system database exists."
    
    # Start MariaDB temporarily to check and potentially configure
    mariadbd --user=mysql --datadir="$DATA_DIR" --skip-networking &
    MARIADB_PID=$!
    
    echo "Waiting for MariaDB to start..."
    for i in {1..30}; do
        if mysqladmin ping --silent 2>/dev/null; then
            echo "MariaDB is ready!"
            break
        fi
        sleep 1
    done
    
    # Try to detect if root password is set by attempting to connect
    # First try without password (fresh install)
    if mysql -u root -e "SELECT 1;" &>/dev/null; then
        echo "Root password not set - this appears to be a fresh installation."
        echo "Creating WordPress database and users..."
        
        mysql -u root <<-EOSQL
            -- Delete anonymous users for security
            DELETE FROM mysql.user WHERE User='';
            
            -- Delete remote root login for security
            DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
            
            -- Set root password
            ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
            
            -- Create the WordPress database
            CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
            
            -- Create users
            CREATE USER '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
            GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
            
            CREATE USER '${MYSQL_SECONDARY_USER}'@'%' IDENTIFIED BY '${MYSQL_SECONDARY_PASSWORD}';
            GRANT SELECT, INSERT, UPDATE, DELETE ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_SECONDARY_USER}'@'%';
            
            FLUSH PRIVILEGES;
EOSQL
        
        if [ $? -eq 0 ]; then
            echo "WordPress database and users created successfully!"
        else
            echo "ERROR: Failed to create database and users!"
        fi
    else
        # Root password is set, check if WordPress database exists
        echo "Root password is set - checking for WordPress database..."
        DB_EXISTS=$(mysql -u root -p"${MYSQL_ROOT_PASSWORD}" -e "SHOW DATABASES LIKE '${MYSQL_DATABASE}';" 2>/dev/null | grep -c "${MYSQL_DATABASE}" || echo "0")
        
        if [ "$DB_EXISTS" = "0" ]; then
            echo "WordPress database not found - creating database and users..."
            
            mysql -u root -p"${MYSQL_ROOT_PASSWORD}" <<-EOSQL
                CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
                
                CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
                GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
                
                CREATE USER IF NOT EXISTS '${MYSQL_SECONDARY_USER}'@'%' IDENTIFIED BY '${MYSQL_SECONDARY_PASSWORD}';
                GRANT SELECT, INSERT, UPDATE, DELETE ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_SECONDARY_USER}'@'%';
                
                FLUSH PRIVILEGES;
EOSQL
            
            if [ $? -eq 0 ]; then
                echo "WordPress database and users created!"
            else
                echo "ERROR: Failed to create database and users!"
            fi
        else
            echo "WordPress database already exists - skipping database creation."
        fi
    fi
    
    # Stop temporary instance
    if ! kill -s TERM "$MARIADB_PID" || ! wait "$MARIADB_PID"; then
        echo "Temporary MariaDB instance stopped."
    fi
fi

# Start MariaDB as the main process (PID 1)
# exec replaces the shell script with mariadbd, making it PID 1
# This is critical: when Docker sends SIGTERM to stop the container,
# it goes directly to mariadbd, allowing graceful shutdown
echo "Starting MariaDB server..."
exec mariadbd --user=mysql --datadir="$DATA_DIR" --bind-address=0.0.0.0