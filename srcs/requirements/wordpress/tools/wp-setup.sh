#!/bin/bash
set -e

# Required env vars
: "${MYSQL_DATABASE:?Missing MYSQL_DATABASE}"
: "${MYSQL_USER:?Missing MYSQL_USER}"
: "${MYSQL_PASSWORD:?Missing MYSQL_PASSWORD}"
: "${MYSQL_USER:?Missing MYSQL_USER}"
: "${MYSQL_PASSWORD:?Missing MYSQL_PASSWORD}"
: "${MYSQL_EMAIL:?Missing MYSQL_EMAIL}"
: "${DOMAIN_NAME:?Missing DOMAIN_NAME}"
MYSQL_HOST="${MYSQL_HOST:-mariadb}"

cd /var/www/html

generate_wp_config() {
    if [ ! -f wp-config.php ]; then
        echo "Generating wp-config.php..."
        cp wp-config-sample.php wp-config.php

        sed -i "s/database_name_here/${MYSQL_DATABASE}/" wp-config.php
        sed -i "s/username_here/${MYSQL_USER}/" wp-config.php
        sed -i "s/password_here/${MYSQL_PASSWORD}/" wp-config.php
        sed -i "s/localhost/${MYSQL_HOST}/" wp-config.php
    fi
}

wait_for_db() {
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
        sleep 2
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

        touch /var/www/html/.wp-installed
    fi
}

generate_wp_config
wait_for_db
install_wp

sed -i 's|^listen = .*|listen = 0.0.0.0:9000|' /etc/php/8.2/fpm/pool.d/www.conf

echo "Starting php-fpm..."
exec php-fpm8.2 -F
