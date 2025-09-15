# syntax=docker/dockerfile:1
FROM debian:bookworm
RUN apt-get update && apt-get install -y mariadb-server
RUN usermod -u 1000 mysql && groupmod -g 1000 mysql
COPY tools/script.sh .
COPY tools/healthcheck.sh /root/healthcheck.sh
COPY config/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf
RUN mkdir -p /var/run/mysqld && chown -R mysql:mysql /var/run/mysqld
RUN mkdir -p /var/lib/mysql && chown -R mysql:mysql /var/lib/mysql
EXPOSE 3306
ENTRYPOINT ["./script.sh"]
