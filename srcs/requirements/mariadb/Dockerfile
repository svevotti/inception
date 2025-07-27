# syntax=docker/dockerfile:1
FROM debian:bullseye
RUN apt-get update && apt-get install -y mariadb-server
RUN mkdir -p /var/run/mysqld && chown -R mysql:mysql /var/run/mysqld
COPY script.sh .
COPY healthcheck.sh /root/healthcheck.sh
COPY config/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf
EXPOSE 3306
ENTRYPOINT ["./script.sh"]