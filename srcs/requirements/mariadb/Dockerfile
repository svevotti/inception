# syntax=docker/dockerfile:1
FROM debian:bullseye
RUN apt-get update && apt-get install -y mariadb-server
COPY script.sh .
COPY /config/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf
RUN mkdir -p /var/run/mysqld && chown -R mysql:mysql /var/run/mysqld
# RUN mkdir -p /var/lib/mysqld && chown -R mysql:mysql /var/lib/mysqld
EXPOSE 3306
ENTRYPOINT ["./script.sh"]
CMD ["--init-file=/docker-entrypoint-initdb.d/init.sql"]