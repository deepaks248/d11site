# Use official PHP 8.3 FPM image (no Apache)
FROM php:8.3-fpm

# Set working directory
WORKDIR /var/www/html

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libwebp-dev \
    libzip-dev \
    unzip \
    zip \
    git \
    libxml2-dev \
    libonig-dev \
    && rm -rf /var/lib/apt/lists/*

# Install required PHP extensions for Drupal
RUN docker-php-ext-configure gd --with-jpeg --with-webp \
    && docker-php-ext-install -j$(nproc) \
        gd \
        pdo \
        pdo_mysql \
        opcache \
        zip \
        dom \
        simplexml \
        mbstring

# Install Composer
COPY --from=composer/composer:latest-bin /composer /usr/bin/composer

# Copy project files
COPY . .

# Set permissions for Drupal files directory
RUN chown -R www-data:www-data web/sites

# Install dependencies (assuming vendor is not mounted)
RUN composer install --no-dev --no-interaction --optimize-autoloader

# Expose PHP-FPM port
EXPOSE 9000

# Optional: set user
USER www-data
