FROM debian:bullseye
RUN apt-get update && apt-get install -y nginx
COPY /config/default /etc/nginx/sites-available/default
# COPY index.html /var/www/html/index.html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]