# syntax=docker/dockerfile:1
FROM debian:bullseye
# RUN groupadd -g 74 mysql && useradd -g mysql -c "MySQL Server,,," -u 74 mysql -d/nonexistent -s/bin/false
RUN apt-get update && apt-get install -y mariadb-server
# RUN mkdir -p /etc/mysql/docker-entrypoint-initdb.d
# RUN chmod -R 777 /etc/mysql/docker-entrypoint-initdb.d/init.sql
COPY script.sh .
COPY healthcheck.sh /root/healthcheck.sh
# RUN chmod -R 777 script.sh
COPY config/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf
# RUN chown mysql:mysql script.sh
RUN mkdir -p /var/run/mysqld && chown -R mysql:mysql /var/run/mysqld
# RUN mkdir -p /var/test && chown -R mysql:mysql /var/test
EXPOSE 3306
# USER 74
ENTRYPOINT ["./script.sh"]