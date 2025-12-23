#!/bin/bash
set -e

echo "Static website container starting..."
echo "Files are ready to be served by NGINX"

# inotifywait to keep container alive while monitoring for file changes
exec inotifywait -m -r /var/www/portfolio -e modify,create,delete,move