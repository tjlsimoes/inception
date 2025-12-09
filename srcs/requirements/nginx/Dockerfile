FROM debian:bookworm-slim

# Install nginx + openssl
RUN apt-get update && apt-get install -y --no-install-recommends \
    nginx openssl curl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create directory for TLS certificates
RUN mkdir -p /etc/nginx/ssl

# Create self-signed certificate
RUN openssl req -x509 -nodes -days 365 \
    -newkey rsa:4096 \
    -keyout /etc/nginx/ssl/nginx.key \
    -out /etc/nginx/ssl/nginx.crt \
    -subj "/CN=${DOMAIN_NAME}"

# Copy config
COPY conf/nginx.conf /etc/nginx/nginx.conf

# Copy the script into container
COPY tools/nginx-init.sh /usr/local/bin/nginx-init.sh
RUN chmod +x /usr/local/bin/nginx-init.sh

# Use script as entrypoint
ENTRYPOINT ["/usr/local/bin/nginx-init.sh"]
