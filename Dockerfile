# Use PHP 7.4 with Apache (official image)
FROM php:7.4-apache

# Install system dependencies
RUN apt-get update && apt-get install -y \
    default-mysql-client \
    && rm -rf /var/lib/apt/lists/*

# Install PHP extensions for MySQL
RUN docker-php-ext-install mysqli pdo pdo_mysql

# Enable Apache mod_rewrite
RUN a2enmod rewrite

# Set working directory
WORKDIR /var/www/html

# Copy application files from root directory
COPY . /var/www/html/

# Create uploads directory and set proper permissions
RUN mkdir -p /var/www/html/uploads && chmod 777 /var/www/html/uploads

# Expose port 80
EXPOSE 80

# Start Apache
CMD ["apache2-foreground"] 