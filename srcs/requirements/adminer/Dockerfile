FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    php-mysqli php-cli ca-certificates wget \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /var/www/html

RUN wget https://www.adminer.org/latest-mysql-en.php -O index.php \
    && chown www-data:www-data index.php

# Use PHP built-in server (no infinite loop hacks!)
EXPOSE 8080
CMD ["php", "-S", "0.0.0.0:8080", "-t", "/var/www/html"]