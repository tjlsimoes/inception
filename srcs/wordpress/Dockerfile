FROM debian:12-slim

ARG DEBIAN_FRONTEND=noninteractive

# Install PHP-FPM and necessary extensions
RUN apt-get update && apt-get install -y --no-install-recommends \
    php8.2-fpm \
    php8.2-mysql \
    php8.2-cli \
    wget \
    unzip \
    pwgen \
    && rm -rf /var/lib/apt/lists/*

# Copy entrypoint script
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

WORKDIR /var/www/html

EXPOSE 9000

CMD ["/usr/local/bin/entrypoint.sh"]