#!/bin/bash
set -e

# Helper function to load from secret file if _FILE is provided
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
load_if_file "MYSQL_HOST"
load_if_file "MYSQL_DATABASE"
load_if_file "MYSQL_USER"
load_if_file "MYSQL_PASSWORD"
load_if_file "MYSQL_EMAIL"
load_if_file "DOMAIN_NAME"
load_if_file "WP_SECONDARY_USER"
load_if_file "WP_SECONDARY_USER_EMAIL"
load_if_file "WP_SECONDARY_USER_PASSWORD"

# Set defaults
MYSQL_HOST="${MYSQL_HOST:-mariadb}"

# Required checks
: "${MYSQL_DATABASE:?Missing MYSQL_DATABASE (or MYSQL_DATABASE_FILE)}"
: "${MYSQL_USER:?Missing MYSQL_USER (or MYSQL_USER_FILE)}"
: "${MYSQL_PASSWORD:?Missing MYSQL_PASSWORD (or MYSQL_PASSWORD_FILE)}"
: "${MYSQL_EMAIL:?Missing MYSQL_EMAIL (or MYSQL_EMAIL_FILE)}"
: "${DOMAIN_NAME:?Missing DOMAIN_NAME (or DOMAIN_NAME_FILE)}"
: "${WP_SECONDARY_USER:?Missing WP_SECONDARY_USER (or WP_SECONDARY_USER_FILE)}"
: "${WP_SECONDARY_USER_PASSWORD:?Missing WP_SECONDARY_USER_PASSWORD (or WP_SECONDARY_USER_PASSWORD_FILE)}"
: "${WP_SECONDARY_USER_EMAIL:?Missing WP_SECONDARY_USER_EMAIL (or WP_SECONDARY_USER_EMAIL_FILE)}"

cd /var/www/html

generate_wp_config() {
    if [ ! -f wp-config.php ]; then
        echo "Generating wp-config.php..."
        cp wp-config-sample.php wp-config.php

        # Existing DB replacements
        sed -i "s/database_name_here/${MYSQL_DATABASE}/" wp-config.php
        sed -i "s/username_here/${MYSQL_USER}/" wp-config.php
        sed -i "s/password_here/${MYSQL_PASSWORD}/" wp-config.php
        sed -i "s/localhost/${MYSQL_HOST}/" wp-config.php

        # Add Redis configuration constants
        sed -i "/\/\* That's all, stop editing! Happy publishing. \*\//i \
define( 'WP_REDIS_HOST', 'redis' );\n\
define( 'WP_REDIS_PORT', 6379 );\n\
define( 'WP_REDIS_TIMEOUT', 1 );\n\
define( 'WP_REDIS_READ_TIMEOUT', 1 );\n\
define( 'WP_REDIS_DATABASE', 0 );\n\
define( 'WP_REDIS_PREFIX', '${DOMAIN_NAME}:' );\n\
" wp-config.php

        sed -i "/\/\* That's all, stop editing! \*\//i \
// Redis Object Cache configuration (added automatically)\n\
" wp-config.php
    fi
}


wait_for_db() {

    TIMEOUT=${WAIT_TIMEOUT:-60}  # seconds
    INTERVAL=2                    # seconds per check
    ELAPSED=0
    echo "Waiting for MariaDB (${MYSQL_HOST})..."
    while true; do
        php <<PHP
<?php
\$m = @new mysqli(
    getenv("MYSQL_HOST"),
    getenv("MYSQL_USER"),
    getenv("MYSQL_PASSWORD"),
    getenv("MYSQL_DATABASE")
);
if (\$m->connect_errno) exit(1);
?>
PHP
        if [ $? -eq 0 ]; then
            echo "MariaDB is ready!"
            break
        fi

        if [ "$ELAPSED" -ge "$TIMEOUT" ]; then
        echo "ERROR: WordPress not reachable after $TIMEOUT seconds."
        exit 1
        fi
        sleep $INTERVAL
        ELAPSED=$((ELAPSED + INTERVAL))
    done
}

install_wp() {
    if [ ! -f /var/www/html/.wp-installed ]; then
        echo "Installing WP-CLI..."
        curl -s -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
        chmod +x wp-cli.phar
        mv wp-cli.phar /usr/local/bin/wp

        echo "Installing WordPress..."
        wp core install \
            --url="${DOMAIN_NAME}" \
            --title="Inception Site" \
            --admin_user="${MYSQL_USER}" \
            --admin_password="${MYSQL_PASSWORD}" \
            --admin_email="${MYSQL_EMAIL}" \
            --skip-email \
            --allow-root \
            --path="/var/www/html"

        echo "Creating secondary WordPress user..."
        wp user create "${WP_SECONDARY_USER}" "${WP_SECONDARY_USER_EMAIL}" \
            --role=subscriber \
            --user_pass="${WP_SECONDARY_USER_PASSWORD}" \
            --display_name="${WP_SECONDARY_USER}" \
            --allow-root \
            --path="/var/www/html"

        touch /var/www/html/.wp-installed

        echo "Installing and enabling Redis Object Cache plugin..."

        # Install the plugin (downloads from wordpress.org if not present)
        wp plugin install redis-cache --activate --allow-root

        # Enable the object cache drop-in
        wp redis enable --allow-root

        # Verify status
        wp redis status --allow-root
    fi
}

generate_wp_config
wait_for_db
install_wp

sed -i 's|^listen = .*|listen = 0.0.0.0:9000|' /etc/php/8.2/fpm/pool.d/www.conf
sed -i 's|^;pm.status_path = .*|pm.status_path = /status|' /etc/php/8.2/fpm/pool.d/www.conf
sed -i 's|^;ping.path = .*|ping.path = /ping|' /etc/php/8.2/fpm/pool.d/www.conf
sed -i 's|^;ping.response = .*|ping.response = pong|' /etc/php/8.2/fpm/pool.d/www.conf

echo "Starting php-fpm..."
exec php-fpm8.2 -F
