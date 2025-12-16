FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl \
    && rm -rf /var/lib/apt/lists/*

# Download and extract the full Portainer package
RUN curl -L https://github.com/portainer/portainer/releases/download/2.36.0/portainer-2.36.0-linux-amd64.tar.gz -o portainer.tar.gz \
    && tar -xzf portainer.tar.gz -C /usr/local/ \
    && rm portainer.tar.gz

# Create data directory
RUN mkdir -p /data

COPY tools/portainer-init.sh /portainer-init.sh
RUN chmod +x /portainer-init.sh

EXPOSE 9443

VOLUME /data

WORKDIR /usr/local/portainer

ENTRYPOINT ["/portainer-init.sh"]