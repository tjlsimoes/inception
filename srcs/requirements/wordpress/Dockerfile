FROM debian:bookworm-slim

# Install dependencies for PHP + WordPress
RUN apt-get update && apt-get install -y --no-install-recommends \
    php-fpm php-mysql php-cli php-curl php-gd php-mbstring php-xml php-zip \
    php-intl php-soap php-bcmath php-redis \
    curl tar ca-certificates libfcgi-bin \
    && update-ca-certificates \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# WordPress installation directory
WORKDIR /var/www/html

# Download WordPress
RUN curl -o wordpress.tar.gz https://wordpress.org/latest && \
    tar -xzf wordpress.tar.gz --strip-components=1 && \
    rm wordpress.tar.gz

# Copy entrypoint script
COPY tools/wp-setup.sh /usr/local/bin/wp-setup.sh
RUN chmod +x /usr/local/bin/wp-setup.sh

EXPOSE 9000

# Run php-fpm as PID 1
ENTRYPOINT ["/usr/local/bin/wp-setup.sh"]
