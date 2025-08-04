# syntax=docker/dockerfile:1
FROM debian:bookworm
RUN apt-get update && apt-get install -y wget php php-mysql php-fpm php-gd
RUN wget https://wordpress.org/latest.tar.gz && tar -xvzf latest.tar.gz && rm -rf latest.tar.gz
RUN mkdir -p /var/www/html && mv wordpress/* /var/www/html && chown -R www-data:www-data /var/www/html/*
RUN wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
RUN chmod +x wp-cli.phar && mv wp-cli.phar /usr/local/bin/wp
COPY config/www.conf /etc/php/7.4/fpm/pool.d/www.conf
RUN chown -R www-data:www-data /etc/php/7.4/fpm/pool.d/www.conf
COPY config/wp-config.php /var/www/html/wp-config.php
WORKDIR /var/www/html
RUN chown -R www-data:www-data .
RUN mkdir -p /run/php && chown -R www-data:www-data /run/php
RUN mkdir -p /var/log && chown -R www-data:www-data /var/log
COPY script.sh /usr/local/bin/script.sh
RUN chmod +x /usr/local/bin/script.sh && chown www-data:www-data /usr/local/bin/script.sh
# RUN mkdir -p /var/www/.wp-cli/cache && chown -R www-data:www-data /var/www/.wp-cli && chmod -R 755 /var/www/.wp-cli
EXPOSE 9000
USER www-data
ENTRYPOINT ["/usr/local/bin/script.sh"]