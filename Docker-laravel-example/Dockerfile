# Use official PHP FPM image as base
FROM php:8.2-fpm

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Create non-root user and group
RUN addgroup --system laravel && \
    adduser --system --ingroup laravel laravel-user

# Set working directory
WORKDIR /var/www/html

# Copy entrypoint script and make it executable
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Copy application code into image
COPY --chown=laravel-user:laravel . .

# Switch to non-root user
USER laravel-user

# Run Composer install and generate key
RUN cd /var/www/html && composer install --no-scripts --no-autoloader

# Entrypoint will run before CMD
ENTRYPOINT ["/entrypoint.sh"]