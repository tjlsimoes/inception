FROM debian:12-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    nginx openssl \
    && rm -rf /var/lib/apt/lists/*

COPY conf.d /etc/nginx/conf.d
COPY certs /etc/nginx/certs

EXPOSE 443

CMD ["nginx", "-g", "daemon off;"]