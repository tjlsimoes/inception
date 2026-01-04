#!/bin/bash
# Initialize .env and secret files
# Will interactively prompt for any missing required values

set -e  # Exit on any error

# ==================== Helper function to prompt if unset ====================
prompt_if_unset() {
    local var_name="$1"
    local description="$2"
    local value="${!var_name}"

    if [[ -z "$value" ]]; then
        echo -n "Please enter $description: "
        read -r value
        if [[ -z "$value" ]]; then
            echo "Error: $description is required and cannot be empty." >&2
            exit 1
        fi
    fi

    # Export so it's available to the rest of the script
    export "$var_name"="$value"
}

# ==================== Prompt for all required variables if not set ====================

echo "Checking required configuration..."

# Non-sensitive (.env)
prompt_if_unset LOGIN               "login (e.g., your 42 login)"
prompt_if_unset DOMAIN_NAME         "domain name (e.g., yourlogin.42.fr)"

# MariaDB
prompt_if_unset MYSQL_DATABASE      "MariaDB database name"
prompt_if_unset MYSQL_ROOT_PASSWORD "MariaDB root password"
prompt_if_unset MYSQL_USER          "MariaDB WordPress user"
prompt_if_unset MYSQL_PASSWORD      "MariaDB WordPress user password"
prompt_if_unset MYSQL_EMAIL         "WordPress admin email"

# WordPress secondary user
prompt_if_unset WP_SECONDARY_USER           "WordPress secondary username"
prompt_if_unset WP_SECONDARY_USER_EMAIL     "WordPress secondary user email"
prompt_if_unset WP_SECONDARY_USER_PASSWORD  "WordPress secondary user password"

# FTP
prompt_if_unset FTP_USER     "FTP username"
prompt_if_unset FTP_PASS     "FTP password"

# Portainer
prompt_if_unset PORTAINER_ADMIN_PASSWORD "Portainer admin password"

# ==================== Paths ====================
ENV_FILE="./srcs/.env"
SECRETS_DIR="./secrets"

echo ""
echo "Creating secrets directory..."
mkdir -p "$SECRETS_DIR"

echo "Creating/updating $ENV_FILE..."
cat > "$ENV_FILE" << EOF
LOGIN=$LOGIN
DOMAIN_NAME=$DOMAIN_NAME
HOSTS_FILE="/etc/hosts"
TEMP_FILE="/tmp/hosts.tmp"
EOF

echo "Creating secret files in $SECRETS_DIR (skipping if already exist)..."

write_secret() {
    local name="$1"
    local value="$2"
    local file="$SECRETS_DIR/${name}.txt"

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
echo "You can re-run this script anytime. Missing values will be prompted again,"
echo "and existing secret files will not be overwritten."