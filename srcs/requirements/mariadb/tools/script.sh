#!/bin/bash

#creating directory for entrypoint script
DOCKER_INIT_DIR=/etc/mysql/docker-entrypoint-initdb.d
INIT_SQL_PATH=$DOCKER_INIT_DIR/init.sql
mkdir $DOCKER_INIT_DIR

#reading password from file
USER_PASS=$(cat $MYSQL_PASSWORD)

#adding database and user for wp
echo "CREATE DATABASE $MYSQL_DATABASE;" > $INIT_SQL_PATH
echo "USE $MYSQL_DATABASE;" >> $INIT_SQL_PATH
echo "CREATE USER '$MYSQL_USER'@'%' IDENTIFIED BY '$USER_PASS';" >> $INIT_SQL_PATH
echo "GRANT ALL PRIVILEGES ON $MYSQL_DATABASE.* TO '$MYSQL_USER'@'%';" >> $INIT_SQL_PATH
echo "FLUSH PRIVILEGES;" >> $INIT_SQL_PATH

#starting mariadb
cat $INIT_SQL_PATH
mariadbd --init-file=$DOCKER_INIT_DIR/init.sql $@