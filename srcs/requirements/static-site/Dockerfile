FROM debian:bookworm-slim

# Install minimal dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    inotify-tools \
    && rm -rf /var/lib/apt/lists/*

# Create directory for public files
RUN mkdir -p /var/www/public

# Copy public website files
COPY public/ /var/www/public/

# Copy entrypoint script
COPY tools/entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh

# Set proper permissions
RUN chown -R www-data:www-data /var/www/public

WORKDIR /var/www/public

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]