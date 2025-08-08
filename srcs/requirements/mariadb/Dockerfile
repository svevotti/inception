# syntax=docker/dockerfile:1
FROM debian:bookworm
RUN apt-get update && apt-get install -y mariadb-server
COPY tools/script.sh .
COPY tools/healthcheck.sh /root/healthcheck.sh
COPY config/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf
RUN mkdir -p /var/run/mysqld && chown -R mysql:mysql /var/run/mysqld
EXPOSE 3306
ENTRYPOINT ["./script.sh"]