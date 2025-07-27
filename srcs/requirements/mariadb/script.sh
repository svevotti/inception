#!/bin/bash

# mysql_install_db --user=mysql --datadir=/var/lib/mysql - do i need to?
USER_PASS=$(cat $MYSQL_PASSWORD)
DOCKER_INIT_DIR=/etc/mysql/docker-entrypoint-initdb.d
INIT_SQL_PATH=$DOCKER_INIT_DIR/init.sql

# Create directory for init.sql
mkdir -p $DOCKER_INIT_DIR

# Write SQL commands in init.sql
echo "CREATE DATABASE $MYSQL_DATABASE;" >> $INIT_SQL_PATH
echo "USE $MYSQL_DATABASE;" >> $INIT_SQL_PATH
echo "CREATE USER '$MYSQL_USER'@'%' IDENTIFIED BY '$USER_PASS';" >> $INIT_SQL_PATH
echo "GRANT ALL PRIVILEGES ON $MYSQL_DATABASE.* TO '$MYSQL_USER'@'%';" >> $INIT_SQL_PATH
echo "FLUSH PRIVILEGES;" >> $INIT_SQL_PATH

# Read the content of init.sql
cat $INIT_SQL_PATH

# Start mariadb
mariadbd --init-file=$INIT_SQL_PATH $@