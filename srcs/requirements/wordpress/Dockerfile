# syntax=docker/dockerfile:1
FROM debian:bullseye
RUN apt-get update && apt-get install -y wget apache2 php php-mysql
RUN wget https://wordpress.org/latest.tar.gz
RUN tar -xvzf latest.tar.gz
RUN mv wordpress/* /var/www/html/
RUN chown -R www-data:www-data /var/www/html
RUN rm -rf wordpress latest.tar.gz
RUN rm -rf /var/www/html/index.html
EXPOSE 80
CMD ["apache2ctl", "-D", "FOREGROUND"]