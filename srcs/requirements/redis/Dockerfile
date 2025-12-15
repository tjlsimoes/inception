FROM debian:bookworm-slim

# Install tools for adding repo
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    && rm -rf /var/lib/apt/lists/*

# Add official Redis repo and key
RUN curl -fsSL https://packages.redis.io/gpg | gpg --dearmor -o /usr/share/keyrings/redis-archive-keyring.gpg \
    && chmod 644 /usr/share/keyrings/redis-archive-keyring.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/redis-archive-keyring.gpg] https://packages.redis.io/deb $(lsb_release -cs) main" > /etc/apt/sources.list.d/redis.list

# Install Redis
RUN apt-get update && apt-get install -y --no-install-recommends \
    redis \
    && rm -rf /var/lib/apt/lists/*

# Create redis user (for security, like official image)
RUN adduser --system --group --no-create-home redis \
    && mkdir /data \
    && chown redis:redis /data

# Config and data dir
VOLUME /data
EXPOSE 6379

COPY conf/redis.conf /etc/redis/redis.conf
RUN chown redis:redis /etc/redis/redis.conf

# Run as redis user
USER redis

CMD ["redis-server", "/etc/redis/redis.conf"]