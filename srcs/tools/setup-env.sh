#!/bin/bash
# setup-secrets.sh
# Initialize .env and all secret files for the Inception project
# Customize the variables below to your liking before running the script

set -e  # Exit on any error

# ==================== CUSTOMIZE THESE VALUES ====================
# Non-sensitive (for .env)
LOGIN="${LOGIN:-tjorge-l}"
DOMAIN_NAME="${DOMAIN_NAME:-tjorge-l.42.fr}"

# MariaDB
MYSQL_DATABASE="${MYSQL_DATABASE:-inception_db}"
MYSQL_ROOT_PASSWORD="${MYSQL_ROOT_PASSWORD:-even_longer_root_password_42}"
MYSQL_USER="${MYSQL_USER:-wp_user}"
MYSQL_PASSWORD="${MYSQL_PASSWORD:-this_is_a_very_long_password_42}"
MYSQL_EMAIL="${MYSQL_EMAIL:-tjorge-l@gmail.com}"

# WordPress secondary user
WP_SECONDARY_USER="${WP_SECONDARY_USER:-commenter}"
WP_SECONDARY_USER_EMAIL="${WP_SECONDARY_USER_EMAIL:-commenter@example.com}"
WP_SECONDARY_USER_PASSWORD="${WP_SECONDARY_USER_PASSWORD:-another_secure_pass456}"

# FTP
FTP_USER="${FTP_USER:-ftpuser}"
FTP_PASS="${FTP_PASS:-strongpasswordhere}"

# Portainer
PORTAINER_ADMIN_PASSWORD="${PORTAINER_ADMIN_PASSWORD:-YourSecurePassword123!}"
# ================================================================

# Paths
ENV_FILE="./srcs/.env"
SECRETS_DIR="./secrets"

echo "Creating secrets directory..."
mkdir -p "$SECRETS_DIR"

echo "Creating $ENV_FILE..."
cat > "$ENV_FILE" << EOF
LOGIN=$LOGIN
DOMAIN_NAME=$DOMAIN_NAME
HOSTS_FILE="/etc/hosts"
TEMP_FILE="/tmp/hosts.tmp"
EOF

echo "Creating secret files in $SECRETS_DIR..."

write_secret() {
    local name="$1"
    local value="$2"
    local file="$SECRETS_DIR/${name}.txt"

    # Only create if it doesn't already exist (preserves custom changes)
    if [ ! -f "$file" ]; then
        echo -n "$value" > "$file"
        echo "  → ${name}.txt created"
    else
        echo "  → ${name}.txt already exists (skipped)"
    fi
}

# MariaDB
write_secret "mysql_database"           "$MYSQL_DATABASE"
write_secret "mysql_root_password"      "$MYSQL_ROOT_PASSWORD"
write_secret "mysql_user"               "$MYSQL_USER"
write_secret "mysql_password"           "$MYSQL_PASSWORD"
write_secret "mysql_email"              "$MYSQL_EMAIL"

# WordPress
write_secret "wp_secondary_user"        "$WP_SECONDARY_USER"
write_secret "wp_secondary_user_email"  "$WP_SECONDARY_USER_EMAIL"
write_secret "wp_secondary_user_password" "$WP_SECONDARY_USER_PASSWORD"

# FTP
write_secret "ftp_user"                 "$FTP_USER"
write_secret "ftp_password"             "$FTP_PASS"

# Portainer
write_secret "portainer_admin_password" "$PORTAINER_ADMIN_PASSWORD"

echo ""
echo "Setup complete!"
echo "  • $ENV_FILE created/updated"
echo "  • Secret files created in $SECRETS_DIR/ (existing files preserved)"
echo ""
echo "Tip: You can override any value by exporting the variable before running:"
echo "  Example:"
echo "    export MYSQL_ROOT_PASSWORD=\"my_strong_password123\""
echo "    ./setup-secrets.sh"
