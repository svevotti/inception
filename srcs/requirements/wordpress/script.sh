#!/bin/bash


ADMIN_PASS=$(cat $ADMIN_PASSWORD_FILE)
# Update website
wp core update --allow-root
# Create website and admin (finishing installation)
wp core install --url="$DOMAIN:$PORT" --title="$TITLE" --admin_user="$ADMIN_USER" --admin_password="$ADMIN_PASS" --admin_email="$ADMIN_USER@example.com" --path="/var/www/html" --allow-root
# Create second user
wp user create kam kam@example.com --role=subscriber --first_name=Kam --last_name=Aliev --user_pass=2 --path=/var/www/html --allow-root

# Start php
/usr/sbin/php-fpm7.4 -F