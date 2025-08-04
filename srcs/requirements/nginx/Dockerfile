FROM debian:bookworm
RUN apt-get update && apt-get install -y nginx openssl curl
RUN mkdir -p /var/lib/nginx/body && chown -R www-data:www-data /var/lib/nginx
# COPY config/default.config /etc/nginx/conf.d/default.config
COPY config/default /etc/nginx/sites-available/default
COPY config/nginx.conf /etc/nginx/nginx.conf
# EXPOSE 8080
EXPOSE 443
USER www-data
CMD ["nginx", "-g", "daemon off;"]