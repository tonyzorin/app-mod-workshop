# Use PHP 5.6 with Apache to match MySQL 5.6
FROM php:5.6-apache

# Install system dependencies and Cloud SQL Proxy
RUN apt-get update && apt-get install -y \
    default-mysql-client \
    wget \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Install Cloud SQL Proxy
RUN wget https://dl.google.com/cloudsql/cloud_sql_proxy.linux.amd64 -O cloud_sql_proxy \
    && chmod +x cloud_sql_proxy \
    && mv cloud_sql_proxy /usr/local/bin/

# Install PHP extensions for MySQL
RUN docker-php-ext-install mysqli pdo pdo_mysql

# Enable Apache mod_rewrite
RUN a2enmod rewrite

# Configure Apache for Cloud Run
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf
RUN sed -i 's/Listen 80/Listen 8080/' /etc/apache2/ports.conf
RUN sed -i 's/<VirtualHost \*:80>/<VirtualHost *:8080>/' /etc/apache2/sites-enabled/000-default.conf

# Set working directory
WORKDIR /var/www/html

# Copy application files from root directory
COPY . /var/www/html/

# Create uploads directory and set proper permissions
RUN mkdir -p /var/www/html/uploads && chmod 777 /var/www/html/uploads

# Set proper permissions for Apache
RUN chown -R www-data:www-data /var/www/html
RUN chmod -R 755 /var/www/html

# Expose port 8080 (Cloud Run requirement)
EXPOSE 8080

# Start Apache
CMD ["apache2-foreground"] 