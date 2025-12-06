#!/bin/sh
set -e

# Fix ownership of the entire mounted Laravel app
chown -R laravel-user:laravel /var/www/html

# Ensure key directories are writable
chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

# Generate Laravel key if not exists
if [ ! -f ".env" ]; then
    cp .env.example .env
fi

if [ ! -f "bootstrap/cache/config.php" ]; then
    cd /var/www/html && php artisan config:cache
    php artisan route:cache
    php artisan key:generate --force
fi

# Start the main container process
exec "$@"