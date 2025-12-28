FROM debian:bookworm-slim

# Install minimal dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    inotify-tools \
    ca-certificates \
    wget vim \
    && rm -rf /var/lib/apt/lists/*

RUN wget https://github.com/gohugoio/hugo/releases/download/v0.153.2/hugo_extended_0.153.2_linux-amd64.deb \
    && dpkg -i hugo_extended_0.153.2_linux-amd64.deb \
    && rm hugo_extended_0.153.2_linux-amd64.deb

RUN mkdir -p /var/www/portfolio

COPY portfolio/ /var/www/portfolio/

# Copy entrypoint script
COPY tools/entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh

# Set proper permissions
RUN chown -R www-data:www-data /var/www/portfolio/public

WORKDIR /var/www/portfolio

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]