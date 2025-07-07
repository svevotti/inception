#!/bin/bash

mkdir -p /docker-entrypoint-initdb.d

echo "CREATE DATABASE $MYSQL_DATABASE;" > /docker-entrypoint-initdb.d/init.sql
echo "USE $MYSQL_DATABASE;" >> /docker-entrypoint-initdb.d/init.sql
echo "CREATE USER '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';" >> /docker-entrypoint-initdb.d/init.sql
echo "GRANT ALL PRIVILEGES ON $MYSQL_DATABASE TO '$MYSQL_USER'@'%';" >> /docker-entrypoint-initdb.d/init.sql
echo "FLUSH PRIVILEGES;" >> /docker-entrypoint-initdb.d/init.sql

chmod +x /docker-entrypoint-initdb.d/init.sql

cat /docker-entrypoint-initdb.d/init.sql

mariadbd $@