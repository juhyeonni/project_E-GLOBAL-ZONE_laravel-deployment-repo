FROM php:7.2-fpm-alpine

# Set working directory
WORKDIR /var/www/html/E_Global_Zone

RUN apk add --no-cache bash

RUN apk add --no-cache zip libzip-dev
RUN docker-php-ext-configure zip
RUN docker-php-ext-install zip
RUN docker-php-ext-install pdo pdo_mysql
# RUN docker-php-ext-install pdo pdo_mysql zip

# Install composer
RUN apk add --no-cache curl \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

COPY wait-for-it.sh /wait-for-it.sh
RUN chmod +x /wait-for-it.sh

# Install dependencies
COPY composer.json composer.lock ./
RUN composer install --no-autoloader --no-scripts

# Copy entrypoint script and give execution rights
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Copy scheduler_crontab.conf file to the crontabs directory
COPY scheduler_crontab.conf /etc/crontabs

# Apply cron job
RUN crontab /etc/crontabs/scheduler_crontab.conf

ENTRYPOINT [ "/entrypoint.sh" ]