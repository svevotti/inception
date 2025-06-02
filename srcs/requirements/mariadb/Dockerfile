# syntax=docker/dockerfile:1
FROM debian:bullseye
RUN apt-get update && apt-get install -y mariadb-server
COPY config/ /docker-entrypoint-initdb.d/
ENV MARIADB_USER=sve
RUN chmod +x /docker-entrypoint-initdb.d/init.sql
RUN mkdir -p /var/run/mysqld && chown -R mysql:mysql /var/run/mysqld
RUN mkdir -p /var/lib/mysqld && chown -R mysql:mysql /var/lib/mysqld
EXPOSE 3306
ENTRYPOINT ["mariadbd"]
CMD ["--init-file=/docker-entrypoint-initdb.d/init.sql"]