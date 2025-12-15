#!/bin/bash
set -e

# Check required environment variables
if [ -z "$FTP_USER" ] || [ -z "$FTP_PASS" ]; then
    echo "Error: FTP_USER and FTP_PASS must be set"
    exit 1
fi

echo "Setting up FTP server..."

# Create FTP user if it doesn't exist
if ! id "$FTP_USER" &>/dev/null; then
    echo "Creating user: $FTP_USER"
    # Create user with /var/www/html as home directory
    useradd -m -d /var/www/html -s /bin/bash "$FTP_USER"
else
    echo "User $FTP_USER already exists"
fi

# -m: Create home directory
# -d /var/www/html: Set home directory to WordPress volume
# -s /bin/bash: Set login shell (necessary for some FTP operations)

# Set password for FTP user
echo "$FTP_USER:$FTP_PASS" | chpasswd

# Ensure the WordPress directory exists and has correct permissions
mkdir -p /var/www/html
chown -R "$FTP_USER:$FTP_USER" /var/www/html

# Create empty directory for vsftpd's secure_chroot_dir
mkdir -p /var/run/vsftpd/empty

echo "FTP server configured successfully"
echo "User: $FTP_USER"
echo "Home directory: /var/www/html"

# Execute vsftpd in foreground (replacing this process, becoming PID 1)
exec /usr/sbin/vsftpd /etc/vsftpd.conf