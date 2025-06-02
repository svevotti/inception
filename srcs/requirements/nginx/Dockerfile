# syntax=docker/dockerfile:1
FROM debian:bullseye
RUN apt-get update && apt-get install -y nginx
WORKDIR /root/nginx
EXPOSE 5050
CMD ["nginx", "-g", "daemon off;"]