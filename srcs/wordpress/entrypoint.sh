#!/bin/bash
set -euo pipefail


read_secret_file() {
var_name="$1"
file_path="${!var_name:-}"
if [ -n "$file_path" ] && [ -f "$file_path" ]; then
	cat "$file_path"
else
	fallback_name="${var_name%_FILE}"
	echo "${!fallback_name:-}"
fi
}


if [ -z "$(ls -A /var/www/html 2>/dev/null)" ]; then
	echo "[wordpress] Downloading WordPress..."
	wget -q https://wordpress.org/latest.tar.gz -O /tmp/wordpress.tar.gz
	tar -xzf /tmp/wordpress.tar.gz -C /var/www/html --strip-components=1
	rm /tmp/wordpress.tar.gz
	chown -R www-data:www-data /var/www/html
fi


php-fpm --daemonize


DB_HOST=${WORDPRESS_DB_HOST%%:*}
until mysqladmin ping -h"$DB_HOST" --silent; do
	echo "[wordpress] Waiting for MariaDB..."
	sleep 2
done


WP_DB_PASSWORD=$(read_secret_file WP_DB_PASSWORD_FILE)
WP_ADMIN_PASSWORD=$(read_secret_file WP_ADMIN_PASSWORD_FILE)
WP=/usr/local/bin/wp


if ! $WP core is-installed --allow-root --path=/var/www/html >/dev/null 2>&1; then
	echo "[wordpress] Installing WordPress..."
	$WP config create --allow-root --path=/var/www/html --dbname="${WORDPRESS_DB_NAME}" --dbuser="${WORDPRESS_DB_USER}" --dbpass="$WP_DB_PASSWORD" --dbhost="${WORDPRESS_DB_HOST}"
	$WP core install --allow-root --path=/var/www/html --url="https://${WP_SITE_DOMAIN}" --title="Inception Site" --admin_user="${WORDPRESS_ADMIN_USER}" --admin_password="$WP_ADMIN_PASSWORD" --admin_email="${WORDPRESS_ADMIN_EMAIL}"
	SECOND_USER=editor_user
	SECOND_EMAIL=editor@${WP_SITE_DOMAIN}
	SECOND_PASS=$(pwgen -s 20 1)
	$WP user create $SECOND_USER $SECOND_EMAIL --allow-root --user_pass="$SECOND_PASS" --role=editor
	echo "[wordpress] Created second user: $SECOND_USER (email: $SECOND_EMAIL)"
else
	echo "[wordpress] WordPress already installed"
fi


pkill php-fpm || true
exec php-fpm -F