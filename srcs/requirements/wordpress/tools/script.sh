#!/bin/bash

ADMIN_PASS=$(cat $ADMIN_PASSWORD_FILE)
USER_PASS=$(cat $USER_PASSWORD_FILE)

echo $WORDPRESS_DB_NAME
echo $WORDPRESS_DB_USER
echo $WORDPRESS_DB_PASSWORD_FILE
echo $WORDPRESS_DB_HOST

# Update website
wp core update --path=/var/www/html
echo "update wp"

# Create website and admin (finishing installation)
wp core install --url="$DOMAIN:$PORT" --title="$TITLE" --admin_user="$ADMIN_USER" --admin_password="$ADMIN_PASS" --admin_email="$ADMIN_USER@example.com" --path="/var/www/html"
echo "create admin"

# Create second user
wp user create kam kam@example.com --role="$USER_ROLE" --first_name=Kam --last_name=Aliev --user_pass="$USER_PASS" --path=/var/www/html
echo "create user"

# Only registered user can comment
wp option update comment_registration 1

# Start php
/usr/sbin/php-fpm8.2 -F
