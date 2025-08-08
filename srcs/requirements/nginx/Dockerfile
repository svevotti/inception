FROM debian:bookworm
RUN apt-get update && apt-get install -y nginx openssl
COPY config/default /etc/nginx/sites-available/default
EXPOSE 80
EXPOSE 443
CMD ["nginx", "-g", "daemon off;"]