# syntax=docker/dockerfile:1
FROM debian:bullseye
RUN apt-get update && apt-get install -y wget php php-mysql php-fpm
RUN wget https://wordpress.org/latest.tar.gz
RUN tar -xvzf latest.tar.gz
RUN mkdir -p /var/www/html && chown -R www-data:www-data /var/www/html
RUN mv wordpress/* /var/www/html  && chown -R www-data:www-data /var/www/html/wp-content
RUN rm -rf wordpress latest.tar.gz
COPY /config/www.conf /etc/php/7.4/fpm/pool.d/www.conf
COPY /config/wp-config.php /var/www/html/wp-config.php
EXPOSE 9000
RUN mkdir -p /run/php && chown -R www-data:www-data /run/php
CMD ["/usr/sbin/php-fpm7.4", "-F"]