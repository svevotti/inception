#!/bin/bash
set -e
root_password="password"
# Create a new database and user
mysql -uroot -p${root_password} -e "CREATE DATABASE IF NOT EXISTS my_database;"
mysql -uroot -p${root_password} -e "CREATE USER IF NOT EXISTS 'sve'@'%' IDENTIFIED BY sve;"
mysql -uroot -p${root_password} -e "GRANT ALL PRIVILEGES ON my_database.* TO 'sve'@'%';"
mysql -uroot -p${root_password} -e "FLUSH PRIVILEGES;"

echo "Database initialization complete."
