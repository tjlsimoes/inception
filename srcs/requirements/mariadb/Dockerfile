# Use Debian Bookworm as the base image
FROM debian:bookworm-slim

# Install MariaDB server
# --no-install-recommends: only install essential packages, keeps image smaller
# apt-get clean and rm -rf /var/lib/apt/lists/*: clean up to reduce image size
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    mariadb-server \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create the directory where MariaDB stores its data
# This is the standard location for MariaDB on Debian/Ubuntu
RUN mkdir -p /var/lib/mysql && \
    chown -R mysql:mysql /var/lib/mysql

RUN mkdir -p /run/mysqld && \
    chown -R mysql:mysql /run/mysqld

# Copy the entrypoint script into the container
COPY tools/mariadb-init.sh /usr/local/bin/mariadb-init.sh

# Make the entrypoint script executable
RUN chmod +x /usr/local/bin/mariadb-init.sh

# Expose port 3306 (default MariaDB port)
# This doesn't publish the port, just documents it
EXPOSE 3306

# Set the entrypoint script
# This script will run as PID 1 and must exec into mariadbd
ENTRYPOINT ["/usr/local/bin/mariadb-init.sh"]