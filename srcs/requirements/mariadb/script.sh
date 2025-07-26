#!/bin/bash

#mouting volume overwrites onwership contianer's directory; setting back to initial ownership mysql
# chown -R mysql:mysql /var/lib/mysql
# mysql_install_db --user=mysql --datadir=/var/lib/mysql
USER_PASS=$(cat $MYSQL_PASSWORD)
# echo $USER_PASS
# rm -rf /var/lib/mysql/*
DOCKER_INIT_DIR=/etc/mysql/docker-entrypoint-initdb.d
echo "create docker init dir"
INIT_SQL_PATH=$DOCKER_INIT_DIR/init.sql
echo "create init sql path"

mkdir $DOCKER_INIT_DIR
echo "create docker init dir"
# chmod -R 777 $INIT_SQL_PATH
echo "CREATE DATABASE $MYSQL_DATABASE;" > $INIT_SQL_PATH
echo "USE $MYSQL_DATABASE;" >> $INIT_SQL_PATH
echo "CREATE USER '$MYSQL_USER'@'%' IDENTIFIED BY '$USER_PASS';" >> $INIT_SQL_PATH
echo "GRANT ALL PRIVILEGES ON $MYSQL_DATABASE.* TO '$MYSQL_USER'@'%';" >> $INIT_SQL_PATH
echo "FLUSH PRIVILEGES;" >> $INIT_SQL_PATH

cat $INIT_SQL_PATH
# mysql_install_db
mariadbd --init-file=$DOCKER_INIT_DIR/init.sql $@