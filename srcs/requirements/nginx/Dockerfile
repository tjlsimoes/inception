FROM debian:bookworm-slim

# Install nginx + openssl
RUN apt-get update && apt-get install -y --no-install-recommends \
    nginx openssl \
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

# Foreground mode for PID1
CMD ["nginx", "-g", "daemon off;"]
