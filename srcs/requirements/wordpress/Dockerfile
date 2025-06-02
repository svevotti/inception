# syntax=docker/dockerfile:1
FROM debian:bullseye
RUN apt-get update && apt-get install -y mariadb-server
WORKDIR /root/mariadb
EXPOSE 3306
CMD ["mariadbd"]