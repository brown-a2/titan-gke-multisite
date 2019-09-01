# WP dependancies
FROM composer:latest AS composer
COPY composer.json /app/composer.json
RUN composer install -vvv

# Compile frontend assets
# FROM node:8.15.1-stretch AS frontend
# WORKDIR /tmp/clarity
# COPY app/themes/clarity .
# RUN npm install && npm install --global gulp-cli
# RUN gulp build --no-cache

# Application
FROM bitnami/wordpress-nginx:latest
RUN apt-get update && apt-get install -y vim
# Remove preinstalled WP plugins (Bitnami and WP native)
RUN rm -r /opt/bitnami/wordpress/wp-content/plugins/*/ && rm /opt/bitnami/wordpress/wp-content/plugins/hello.php
COPY opt/php/php.ini /opt/bitnami/php/etc/php.ini
COPY opt/nginx/wordpress-vhosts.conf /opt/bitnami/nginx/conf/vhosts/wordpress-vhosts.conf
#COPY app/themes /bitnami/wordpress/wp-content/themes
#COPY --from=frontend /tmp/clarity/assets /bitnami/wordpress/wp-content/themes/clarity/assets
COPY --from=composer /app/bitnami/wordpress/wp-content/plugins /bitnami/wordpress/wp-content/plugins
COPY --from=composer /app/bitnami/wordpress/wp-content/themes /bitnami/wordpress/wp-content/themes