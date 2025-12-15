FROM debian:bookworm-slim

# Install vsftpd
RUN apt-get update && \
    apt-get install -y vsftpd && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create directory for WordPress files
RUN mkdir -p /var/www/html

# Copy configuration and startup script
COPY conf/vsftpd.conf /etc/vsftpd.conf
COPY tools/ftp-init.sh /usr/local/bin/ftp-init.sh

RUN chmod +x /usr/local/bin/ftp-init.sh

# Expose FTP ports
EXPOSE 21 40000-40099

# Run setup script which will exec vsftpd (becoming PID 1)
ENTRYPOINT ["/usr/local/bin/ftp-init.sh"]