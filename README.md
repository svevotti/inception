# Inception - Docker Infrastructure Project

## Table of Contents
- [About](#about)
- [Usage](#usage)
- [Installation](#installation)
  - [Prerequisites](#prerequisites)
  - [Setup](#setup)
	- [Domain Configuration](#domain-configuration)
  	- [Docker Secrets](#docker-secrets)
	- [Environment Variables](#environment-variables)
	- [SSL/TLS Certificate Generation](#ssltls-certificate-generation)
- [Project Structure](#project-structure)
- [Build and Start Services](#build-and-start-services)
	- [Verify Installation](#verify-installation)
- [Access the Application](#access-the-application)
- [Make Commands](#make-commands)

## About

Inception is a Docker infrastructure project in which I had to create a multi-container application environment using Docker Compose. The project involves setting up three interconnected services (NGINX, WordPress, and MariaDB) running in isolated Docker containers with proper SSL/TLS encryption, persistent data storage, and secure configuration management.

## Usage

### Overview

This project leverages Docker and Docker Compose to create a modular, scalable, and maintainable infrastructure. Each service (NGINX, WordPress, MariaDB) runs in its own container, ensuring isolation, portability, and easy management. Docker Compose orchestrates these containers, managing networking, volumes, and environment variables from a single configuration file.

### Sources and Dockerfiles

The project includes custom Dockerfiles for each service:
- **nginx/Dockerfile**: Builds a lightweight NGINX image from Debian with TLS support
- **wordpress/Dockerfile**: Creates a PHP-FPM runtime for WordPress without NGINX
- **mariadb/Dockerfile**: Sets up MariaDB database server with initialization scripts
- **srcs/docker-compose.yml**: Central orchestration configuration for all services

**Important constraint**: No pre-built images are pulled. All images are built from scratch using Debian (penultimate stable - at the time I did the project was bookworm) base images. This ensures full control over dependencies and security.

### Structure

1. **Separation of Concerns**: Each service has a single responsibility
   - NGINX: Reverse proxy and TLS termination
   - WordPress: Application logic via PHP-FPM
   - MariaDB: Data persistence only

2. **Security-First Architecture**:
   - Only NGINX exposes a port to the host (443)
   - Inter-container communication via Docker network bridge
   - Credentials stored in Docker secrets and environment variables
   - No credentials in Dockerfiles or Docker images

3. **Persistent Storage**:
   - Named volumes (not bind mounts) for WordPress files and database
   - Data stored in `/home/login/data/` on host machine
   - Ensures data survives container restarts

4. **Daemon Configuration**:
   - Services run without infinite loops (`tail -f`, `sleep infinity`, etc.)
   - Automatic restart policies for crash recovery

## Installation

### Prerequisites

#### System Requirements
- **Docker & Docker Compose**: Must be installed and running
  ```bash
  docker --version
  docker compose --version
  ```
- **Disk Space**: Minimum 2GB free (plus space for WordPress + database)
- **RAM**: Minimum 2GB available for containers

#### Software Stack Components
- **Base Images**: Debian (penultimate stable)
- **NGINX**: Latest stable with TLSv1.2/TLSv1.3 support
- **WordPress**: Latest stable version
- **PHP-FPM**: Latest stable with required extensions (mysqli, gd, etc.)
- **MariaDB**: Latest stable version

### Setup

#### Domain Configuration

Configure your local domain name to resolve to your machine's IP:

```bash
sudo vim /etc/hosts

# Add this line:
127.0.0.1    smazzari.42.fr

```

#### Docker Secrets

Create the `secrets/` directory and credential files:

```bash
# Create secrets directory
mkdir -p secrets

# Create credential files with strong passwords
echo "your_secure_db_password" > secrets/db_password.txt
echo "your_secure_admin_password" > secrets/admin_password.txt

# Set proper permissions (readable by docker only)
chmod 600 secrets/*.txt
```

#### Environment Variables

Create `srcs/.env` file with this configuration:

```bash
cat > srcs/.env << EOF
DOMAIN_NAME=smazzari.42.fr
DATABASE=my_data
USER_DB=svevish
HOST=db
DOMAIN=smazzari.42.fr
ADMIN_USER=sve
EOF
```

#### SSL/TLS Certificate Generation

This project uses self-signed SSL certificates for HTTPS. Follow these steps to generate certificates for your domain.

##### Prerequisites
- OpenSSL installed on your system

##### Generation
```bash

# Create secret/ssl folder where you will store your certificates
mkdir -p secrets/ssl

# Generate a 2048-bit RSA private key for the domain
openssl genrsa -out smazzari.42.fr.key 2048

# Display the private key content
cat smazzari.42.fr.key

# Create a Certificate Signing Request (CSR) using the private key
openssl req -new -key smazzari.42.fr.key -out smazzari.42.fr.csr

# Verify and display the CSR contents
openssl req -text -in smazzari.42.fr.csr -noout -verify

# Display the CSR file
cat smazzari.42.fr.csr

# Generate a 4096-bit encrypted CA private key (you'll set a passphrase)
openssl genrsa -aes256 -out my_ca.key 4096

# Create a self-signed CA certificate valid for 1 day
openssl req -x509 -new -nodes -key my_ca.key -sha256 -days 1 -out my_ca.crt

# Sign the domain CSR with the CA certificate and private key, valid for 10 days
openssl x509 -req -in smazzari.42.fr.csr -CA my_ca.crt -CAkey my_ca.key -CAcreateserial -out smazzari.42.fr.crt -days 10 -sha256
```
##### Generated Files
- `smazzari.42.fr.key` - Your domain's private key
- `smazzari.42.fr.csr` - Certificate signing request
- `smazzari.42.fr.crt` - Your signed certificate
- `my_ca.key` - CA private key (encrypted)
- `my_ca.crt` - CA certificate
- `my_ca.srl` - CA serial number file

##### Using the Certificates
Configure your web server (Nginx/Apache) to use:
- **Certificate**: `smazzari.42.fr.crt`
- **Private Key**: `smazzari.42.fr.key`

##### Security Notes
⚠️ These are self-signed certificates for development only. Browsers will show security warnings.

##### Regenerating Certificates
To create new certificates, simply re-run the commands above. Update the validity period (`-days`) as needed.

### Project Structure

At this point, the directory structure should match:

```
inception/
├── Makefile
├── .gitignore
├── README.md
└── srcs/
    ├── docker-compose.yml
    └── requirements/
        ├── nginx/
        │   ├── Dockerfile
        │   ├── .dockerignore
        │   ├── conf/
		│   │   ├── default 
        │   │   └── nginx.conf
        │   └── tools/
        ├── wordpress/
        │   ├── Dockerfile
        │   ├── .dockerignore
        │   ├── conf/
		│   │   ├── wp-config.php 
		│   │   └── www.config
        │   └── tools/
		│       └── script.sh
        ├── mariadb/
        │   ├── Dockerfile
        │   ├── .dockerignore
        │   ├── conf/
		│   │   └── 50-server.cnf
        │   └── tools/
		│       ├── wp-config.php 
		│__     └── www.config
```

## Build and Start Services

```bash
# Build Docker images and start containers
make

# This runs:
# - Builds custom Dockerfile for each service
# - Creates named volumes
# - Starts all containers
# - Configures Docker network
```

### Verify Installation

```bash
# Check if all containers are running
docker ps

# Expected output should show three running containers:
# - nginx
# - wordpress  
# - mariadb

# Check container logs for errors
docker compose -f srcs/docker-compose.yml logs

# Verify volumes were created
docker volume ls | grep inception

# Check data directory on host
ls -la /home/login/data/
```

## Access the Application

Open your web browser and navigate to:

```
https://smazzari.42.fr
```


**Note**: Your browser will show a security warning about the self-signed certificate—this is expected in development. Click "Advanced" and proceed.

## Make Commands

```bash
make              # Build and start all services
make build        # Build Docker images only
make up           # Start containers
make down         # Stop and remove containers
make logs         # View container logs
make clean        # Remove containers and images
make fclean       # Full clean including volumes
make re           # Rebuild and restart
```
---

**Author**: Sveva Mazzari  
**Created**: somewhere summer 2025  
**Last Updated**: summer 2025
