#!/bin/bash
set -euo pipefail

# Read secrets or env files
read_secret() {
  local f="$1"
  if [ -n "${!f+x}" ] && [ -f "${!f}" ]; then
    cat "${!f}"
  else
    # no secret file; fallback to env var without _FILE (not recommended)
    varname="${f%_FILE}"
    echo "${!varname:-}"
  fi
}

MYSQL_ROOT_PASSWORD=$(read_secret MARIADB_ROOT_PASSWORD_FILE)
WP_DB_PASSWORD=$(read_secret WP_DB_PASSWORD_FILE)
WP_ADMIN_PASSWORD=$(read_secret WP_ADMIN_PASSWORD_FILE)
WP_DB_NAME="${WP_DB_NAME:-wordpress_db}"
WP_DB_USER="${WP_DB_USER:-wp_user}"
WP_ADMIN_USER="${WP_ADMIN_USER:-wp_manager}"

# If DB hasn't been initialized, initialize and create users
if [ ! -d "/var/lib/mysql/mysql" ]; then
  echo "Initializing MariaDB data directory ..."
  mysqld --initialize-insecure --user=mysql --datadir=/var/lib/mysql
  # Start server in background
  mysqld --skip-networking --socket=/var/run/mysqld/mysqld.sock --user=mysql &
  pid="$!"
  sleep 2

  # Use mysql client to create DB and users
  mysql=( mysql --protocol=socket -uroot -S /var/run/mysqld/mysqld.sock )

  # optionally set root password
  if [ -n "$MYSQL_ROOT_PASSWORD" ]; then
    "${mysql[@]}" <<-EOSQL
      ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
EOSQL
  fi

  # create database + user
  "${mysql[@]}" <<-EOSQL
    CREATE DATABASE IF NOT EXISTS \`${WP_DB_NAME}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
    CREATE USER IF NOT EXISTS '${WP_DB_USER}'@'%' IDENTIFIED BY '${WP_DB_PASSWORD}';
    GRANT ALL PRIVILEGES ON \`${WP_DB_NAME}\`.* TO '${WP_DB_USER}'@'%';
    FLUSH PRIVILEGES;
EOSQL

  # Create second user (admin) inside WP later or here as DB user (WordPress admin is WP-level)
  # If you want an additional database user, create here.

  # Stop background server and let main CMD run it
  kill "$pid"
  wait "$pid" || true
fi

exec "$@"
