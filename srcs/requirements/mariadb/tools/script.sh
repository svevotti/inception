#!/bin/bash

#creating directory for entrypoint script
DOCKER_INIT_DIR=/etc/mysql/docker-entrypoint-initdb.d
INIT_SQL_PATH=$DOCKER_INIT_DIR/init.sql
mkdir $DOCKER_INIT_DIR

#reading password from file
USER_PASS=$(cat $MYSQL_PASSWORD_FILE)

#adding database and user for wp
cat > $INIT_SQL_PATH << EOF
CREATE DATABASE $MYSQL_DATABASE;
USE $MYSQL_DATABASE;
CREATE USER '$MYSQL_USER'@'%' IDENTIFIED BY '$USER_PASS';
GRANT ALL PRIVILEGES ON $MYSQL_DATABASE.* TO '$MYSQL_USER'@'%';
FLUSH PRIVILEGES;
EOF

#starting mariadb
mariadbd --init-file=$INIT_SQL_PATH $@