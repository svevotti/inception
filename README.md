1) start container with nginx image form DockerHub
	docker run -it --rm -d -p 8080:80 --name web nginx
2) start container with docker compose

# Inception - Docker Infrastructure Project

---

## Description

Inception is a comprehensive Docker-based infrastructure project that demonstrates advanced DevOps practices by creating a multi-container application environment using Docker Compose. The project involves setting up three interconnected services (NGINX, WordPress with PHP-FPM, and MariaDB) running in isolated Docker containers with proper SSL/TLS encryption, persistent data storage, and secure configuration management.

### Project Goal

The goal of Inception is to:
- Understand containerization principles and Docker ecosystem
- Learn multi-container orchestration using Docker Compose
- Implement secure infrastructure patterns (SSL/TLS, secrets management)
- Practice proper daemon configuration and process management
- Build production-ready infrastructure with isolation and persistence
- Master DevOps best practices including networking, volumes, and environment configuration

### Brief Overview

This project creates a fully functional WordPress infrastructure where:
- **NGINX** serves as the only external entry point (port 443, HTTPS only)
- **WordPress + PHP-FPM** handles application logic without exposing network ports
- **MariaDB** manages data securely behind the Docker network
- All services communicate via a custom Docker network bridge
- Data persists using named volumes mapped to the host machine
- Security is enforced through environment variables and Docker secrets

## Project Description

### Overview of Docker Usage

This project leverages Docker and Docker Compose to create a modular, scalable, and maintainable infrastructure. Each service (NGINX, WordPress, MariaDB) runs in its own container, ensuring isolation, portability, and easy management. Docker Compose orchestrates these containers, managing networking, volumes, and environment variables from a single configuration file.

### Sources and Dockerfiles

The project includes custom Dockerfiles for each service:
- **nginx/Dockerfile**: Builds a lightweight NGINX image from Alpine/Debian with TLS support
- **wordpress/Dockerfile**: Creates a PHP-FPM runtime for WordPress without NGINX
- **mariadb/Dockerfile**: Sets up MariaDB database server with initialization scripts
- **srcs/docker-compose.yml**: Central orchestration configuration for all services

**Important constraint**: No pre-built images are pulled. All images are built from scratch using Alpine (penultimate stable) or Debian (penultimate stable) base images. This ensures full control over dependencies and security.

### Main Design Choices

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
   - Proper PID 1 signal handling in containers
   - Automatic restart policies for crash recovery

### Design Comparison: Key Technical Choices

#### Virtual Machines vs Docker

| Aspect | Virtual Machines | Docker (Our Choice) |
|--------|------------------|-------------------|
| **Startup Time** | Minutes | Seconds |
| **Resource Usage** | High (full OS per VM) | Lightweight (shared kernel) |
| **Isolation Level** | Complete OS-level | Process-level via namespaces |
| **Portability** | OS-dependent | Works anywhere Docker runs |
| **Overhead** | Significant | Minimal |
| **Use Case** | Full OS simulation needed | Microservices, fast deployment |
| **Our Reason** | We need fast, portable, efficient services without full VMs | ✅ Perfect fit |

**Why Docker**: We chose Docker because it provides sufficient isolation for this infrastructure while being lightweight and portable. We don't need full OS-level isolation that VMs provide.

#### Secrets vs Environment Variables

| Aspect | Environment Variables | Docker Secrets (Our Choice) |
|--------|----------------------|----------------------------|
| **Visibility** | Visible in logs/processes | Hidden from container processes |
| **Git Safety** | ❌ Easy to accidentally commit | ✅ Never stored in repository |
| **Access Control** | All processes can read | Only specified services access |
| **Rotation** | Requires container restart | Can rotate without restart |
| **Use Case** | Non-sensitive config | Sensitive credentials |
| **Our Approach** | Configuration values (DOMAIN_NAME) | Passwords (MYSQL_PASSWORD, MYSQL_ROOT_PASSWORD) |

**Our Implementation**:
```
# Sensitive credentials → Docker Secrets
secrets/
  ├── db_password.txt
  ├── db_root_password.txt
  └── credentials.txt

# Non-sensitive config → Environment Variables
srcs/.env
  ├── DOMAIN_NAME
  ├── MYSQL_DATABASE
  └── WP_ADMIN_EMAIL
```

#### Docker Network vs Host Network

| Aspect | Docker Network Bridge | Host Network (NOT Used) |
|--------|----------------------|--------------------------|
| **Isolation** | ✅ Containers isolated from host | ❌ No isolation |
| **Port Conflicts** | ✅ Each container has own namespace | ❌ Ports shared with host |
| **Service Discovery** | ✅ DNS-based (service names) | ❌ Must use localhost:port |
| **Security** | ✅ Default deny, explicit allow | ❌ Wide open to host network |
| **Container-to-Container** | ✅ Via bridge | ❌ N/A |
| **Performance** | Minimal overhead | Negligible but loses isolation |

**Our Implementation**:
```yaml
networks:
  inception_network:
    driver: bridge

services:
  nginx:
    networks:
      - inception_network
  wordpress:
    networks:
      - inception_network
  mariadb:
    networks:
      - inception_network
```

This allows NGINX to reach WordPress via `wordpress:9000` and MariaDB via `mariadb:3306` without exposing them to the host.

#### Docker Volumes vs Bind Mounts

| Aspect | Bind Mounts | Docker Volumes (Our Choice) |
|--------|-------------|----------------------------|
| **Management** | Manual path mapping | Docker manages everything |
| **Portability** | Path-dependent (breaks on move) | Works anywhere |
| **Performance** | Can be slow on some systems | Optimized |
| **Permissions** | Host filesystem perms apply | Docker handles transparently |
| **Backup** | Filesystem tools needed | Built-in Docker support |
| **Use Case** | Development with live code | Production data persistence |
| **Our Reason** | Production-grade persistence | ✅ Proper data management |

**Our Implementation**:
```yaml
volumes:
  wordpress_volume:
    driver: local
  mariadb_volume:
    driver: local

# Data stored at:
# /home/login/data/wordpress_volume/
# /home/login/data/mariadb_volume/
```

---

## Architecture

```
┌─────────────────────────────────────────────────┐
│                Host Machine                      │
├─────────────────────────────────────────────────┤
│  ┌──────────────────────────────────────────┐   │
│  │      Docker Network (bridge)             │   │
│  │      inception_network                   │   │
│  ├──────────────────────────────────────────┤   │
│  │  ┌────────────┐  ┌──────────┐  ┌──────┐ │   │
│  │  │   NGINX    │  │WordPress │  │Maria │ │   │
│  │  │  (port443) │  │php-fpm   │  │  DB  │ │   │
│  │  │  TLS 1.2+  │  │(no nginx)│  │      │ │   │
│  │  └────────────┘  └──────────┘  └──────┘ │   │
│  └──────────────────────────────────────────┘   │
│                                                   │
│  /home/login/data/                              │
│  ├── wordpress_volume/                          │
│  └── mariadb_volume/                            │
└─────────────────────────────────────────────────┘
```

### Services Overview

| Service | Image Base | Port | Protocol | Purpose |
|---------|-----------|------|----------|---------|
| **NGINX** | Custom Alpine/Debian | 443 | HTTPS (TLSv1.2+) | Reverse proxy, SSL termination |
| **WordPress** | Custom Alpine/Debian | Internal | Socket | PHP-FPM application |
| **MariaDB** | Custom Alpine/Debian | Internal | Docker Network | Database server |

## Instructions

### Prerequisites

#### System Requirements
- **Docker & Docker Compose**: Must be installed and running
  ```bash
  docker --version
  docker compose --version
  ```
- **Virtual Machine**: Project should run in a VM (recommended for isolation)
- **Linux-based Host OS**: Linux, macOS, or Windows with WSL2
- **Disk Space**: Minimum 2GB free (plus space for WordPress + database)
- **RAM**: Minimum 2GB available for containers

#### Software Stack Components
- **Base Images**: Alpine Linux (penultimate stable) OR Debian (penultimate stable)
- **NGINX**: Latest stable with TLSv1.2/TLSv1.3 support
- **WordPress**: Latest stable version
- **PHP-FPM**: Latest stable with required extensions (mysqli, gd, etc.)
- **MariaDB**: Latest stable version

### Installation & Setup

#### Step 1: Domain Configuration

Configure your local domain name to resolve to your machine's IP:

```bash
# Linux/macOS: Edit /etc/hosts
sudo nano /etc/hosts

# Add this line:
127.0.0.1    login.42.fr

# Replace "login" with your actual 42 username
# Example: 127.0.0.1    sveva.42.fr
```

For Windows: Edit `C:\Windows\System32\drivers\etc\hosts` with Administrator privileges.

#### Step 2: Project Structure Setup

Clone/download the project and ensure the directory structure matches:

```
inception/
├── Makefile
├── secrets/
│   ├── credentials.txt
│   ├── db_password.txt
│   └── db_root_password.txt
└── srcs/
    ├── .env
    ├── docker compose.yml
    └── requirements/
        ├── nginx/
        ├── wordpress/
        ├── mariadb/
        └── tools/
```

#### Step 3: Create Secret Files

Create the `secrets/` directory and credential files:

```bash
# Create secrets directory
mkdir -p secrets

# Create credential files with strong passwords
echo "your_secure_db_password" > secrets/db_password.txt
echo "your_secure_root_password" > secrets/db_root_password.txt
echo "your_secure_wordpress_password" > secrets/credentials.txt

# Set proper permissions (readable by docker only)
chmod 600 secrets/*.txt
```

**⚠️ Important**: Add `secrets/` to `.gitignore` to prevent credentials from being committed:

```bash
echo "secrets/" >> .gitignore
```

#### Step 4: Configure Environment Variables

Create `srcs/.env` file with your configuration:

```bash
cat > srcs/.env << EOF
# Domain Configuration
DOMAIN_NAME=login.42.fr

# Database Configuration
MYSQL_DATABASE=wordpress
MYSQL_USER=wp_user
MYSQL_PASSWORD_FILE=/run/secrets/db_password
MYSQL_ROOT_PASSWORD_FILE=/run/secrets/db_root_password

# WordPress Configuration
WP_ADMIN_USER=wp_master
WP_ADMIN_EMAIL=admin@login.42.fr
WP_ADMIN_PASSWORD_FILE=/run/secrets/credentials
EOF
```

**Note**: Replace `login` with your actual 42 username in DOMAIN_NAME.

#### Step 5: Build and Start Services

```bash
# Build Docker images and start containers
make

# This runs:
# - Builds custom Dockerfile for each service
# - Creates named volumes
# - Starts all containers
# - Configures Docker network
```

#### Step 6: Verify Installation

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

#### Step 7: Access the Application

Open your web browser and navigate to:

```
https://login.42.fr
```

Replace `login` with your actual 42 username.

**Note**: Your browser will show a security warning about the self-signed certificate—this is expected in development. Click "Advanced" and proceed.

### Compilation & Building

#### Build Docker Images

```bash
# Build all images
make build

# This creates three images:
# - inception_nginx:1.0
# - inception_wordpress:1.0
# - inception_mariadb:1.0
```

#### Rebuild from Scratch

```bash
# Clean everything and rebuild
make fclean && make

# This removes all images, volumes, and containers
# Then rebuilds everything from scratch
```

### Service Management Commands

```bash
# Start services
make up

# Stop services (preserves data in volumes)
make down

# Restart services
make re

# View logs from all services
make logs

# Clean containers and images (keeps volumes)
make clean

# Full clean including volumes (WARNING: deletes all data)
make fclean
```

### Database Management

#### Accessing Database

```bash
# From command line using docker compose
docker compose -f srcs/docker-compose.yml exec mariadb mysql -u root -p

# From WordPress container
docker compose -f srcs/docker-compose.yml exec wordpress \
    mysql -h mariadb -u wordpress -p wordpress
```

#### Database Initialization

The MariaDB container automatically initializes on first run:
- Creates the `wordpress` database
- Creates application user with provided credentials
- Sets up proper permissions for WordPress

#### Backup Database

```bash
# Export database
docker compose -f srcs/docker-compose.yml exec mariadb \
    mysqldump -u root -p wordpress > backup.sql

# Import database
docker compose -f srcs/docker-compose.yml exec mariadb \
    mysql -u root -p wordpress < backup.sql
```

---

## Project Structure

### Directory Organization

```
inception/
├── Makefile
├── secrets/
│   ├── credentials.txt          # WordPress user credentials
│   ├── db_password.txt          # Database user password
│   └── db_root_password.txt     # Database root password
└── srcs/
    ├── .env                     # Environment variables
    ├── docker compose.yml       # Docker Compose configuration
    └── requirements/
        ├── nginx/
        │   ├── Dockerfile
        │   ├── .dockerignore
        │   ├── conf/
        │   │   └── nginx.conf
        │   └── tools/
        ├── wordpress/
        │   ├── Dockerfile
        │   ├── .dockerignore
        │   ├── conf/
        │   └── tools/
        ├── mariadb/
        │   ├── Dockerfile
        │   ├── .dockerignore
        │   ├── conf/
        │   └── tools/
        └── tools/               # Shared utilities (optional)
```

## Security Considerations

### ✅ Implemented Best Practices

- **No Hardcoded Credentials**: All sensitive data stored in Docker secrets or environment variables
- **SSL/TLS Encryption**: NGINX configured for TLSv1.2+ only
- **Minimal Attack Surface**: Only NGINX exposed (port 443)
- **Named Volumes**: Persistent data stored securely with proper permissions
- **Custom Dockerfiles**: No pre-built images pulled; full control over dependencies
- **Non-root Processes**: Containers run as non-root users where applicable
- **No Infinite Loops**: Proper daemon configuration without hacky patches

### ⚠️ Important Security Notes

1. **Credentials in Git**: Never commit `secrets/` or `.env` files containing real passwords
2. **Strong Passwords**: Generate cryptographically secure passwords for all services
3. **SSL Certificates**: Self-signed certificates during development; use proper CA for production
4. **User Privileges**: WordPress admin username must not contain "admin" or "administrator"

## 🛠️ Make Commands

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

## 📝 Configuration Details

### NGINX Configuration
- **Port**: 443 (HTTPS only)
- **Protocol**: TLSv1.2 or TLSv1.3
- **Role**: Reverse proxy to WordPress/php-fpm
- **Features**: SSL termination, request routing

### WordPress + PHP-FPM
- **No NGINX**: Runs only php-fpm
- **Communication**: Via Docker network socket to NGINX
- **Volumes**: Mounted WordPress files from named volume
- **Database**: Connected to MariaDB service

### MariaDB
- **Ports**: Internal only (no external exposure)
- **Volumes**: Database files stored in named volume
- **Users**: Administrator + application user (no "admin" username)
- **Backup**: Database persists in `/home/login/data/mariadb_volume/`

## 🔗 Service Communication

```
Client (HTTPS) 
    ↓
  NGINX (port 443)
    ↓
PHP-FPM (internal socket)
    ↓
MariaDB (internal network)
```

All inter-container communication occurs via Docker network bridge—no exposed ports except 443.

## 📋 Database Setup

The MariaDB container automatically initializes with:
- Root user with secure password (via Docker secret)
- Application database: `wordpress`
- Application user: configured in environment variables
- Proper permissions for WordPress operation

### Accessing Database

```bash
# From within the WordPress container
mysql -h mariadb -u wordpress -p wordpress

# Using docker compose
docker compose -f srcs/docker-compose.yml exec mariadb mysql -u root -p
```

## 🐛 Troubleshooting

### Containers Won't Start
```bash
# Check logs for specific errors
docker compose -f srcs/docker-compose.yml logs <service_name>

# Verify Docker network
docker network ls
```

### Database Connection Failed
```bash
# Ensure MariaDB is running
docker compose -f srcs/docker-compose.yml ps

# Verify environment variables
docker compose -f srcs/docker-compose.yml config
```

### SSL Certificate Errors
```bash
# Regenerate self-signed certificate
# (Instructions depend on your NGINX setup)

# Verify certificate
openssl s_client -connect login.42.fr:443
```

### Volumes Not Persisting
```bash
# Check volume contents
docker volume inspect inception_mariadb_volume

# Verify host directory
ls -la /home/login/data/
```

### Permission Denied on Host
```bash
# Ensure proper permissions on /home/login/data/
chmod 755 /home/login/data/
```

---

## Resources

### Official Documentation & References

1. **Docker Documentation**
   - [Docker Documentation Official](https://docs.docker.com/)
   - [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)
   - [Docker Security Best Practices](https://docs.docker.com/develop/security-best-practices/)

2. **Docker Compose**
   - [Docker Compose Reference](https://docs.docker.com/compose/compose-file/)
   - [Docker Compose Specification](https://github.com/compose-spec/compose-spec)
   - [Environment Variables in Compose](https://docs.docker.com/compose/environment-variables/)

3. **NGINX Configuration**
   - [NGINX Official Documentation](https://nginx.org/en/docs/)
   - [SSL/TLS Configuration](https://nginx.org/en/docs/http/ngx_http_ssl_module.html)
   - [Reverse Proxy Configuration](https://docs.nginx.com/nginx/admin-guide/web-server/reverse-proxy/)

4. **WordPress & PHP-FPM**
   - [WordPress Security Guide](https://wordpress.org/support/article/hardening-wordpress/)
   - [WordPress Installation](https://wordpress.org/support/article/how-to-install-wordpress/)
   - [PHP-FPM Configuration](https://www.php.net/manual/en/install.fpm.configuration.php)
   - [WordPress Plugin Development](https://developer.wordpress.org/plugins/)

5. **MariaDB Database**
   - [MariaDB Official Documentation](https://mariadb.com/docs/)
   - [MariaDB Server Documentation](https://mariadb.com/docs/reference/mdb-product-docs/)
   - [Database Security](https://mariadb.com/docs/security/securing-mariadb/)

6. **SSL/TLS Certificates**
   - [Mozilla SSL Configuration](https://ssl-config.mozilla.org/)
   - [OpenSSL Documentation](https://www.openssl.org/docs/)
   - [Let's Encrypt (for production)](https://letsencrypt.org/docs/)

7. **DevOps & Container Best Practices**
   - [The Twelve-Factor App](https://12factor.net/)
   - [Container Best Practices](https://kubernetes.io/docs/concepts/containers/)
   - [Dockerfile Best Practices](https://docs.docker.com/develop/dockerfile_best-practices/)

### Tutorials & Articles

- [Docker for Beginners](https://docker-curriculum.com/)
- [Understanding Docker Volumes](https://www.digitalocean.com/community/tutorials/how-to-work-with-docker-data-volumes-on-ubuntu-16-04)
- [Docker Networking Guide](https://www.digitalocean.com/community/tutorials/how-to-work-with-docker-networks)
- [WordPress on Docker](https://docs.docker.com/samples/wordpress/)
- [NGINX and PHP-FPM Configuration](https://www.digitalocean.com/community/tutorials/how-to-set-up-wordpress-with-docker compose)

---

### AI Usage Disclosure

This README and related documentation were created with AI assistance (Claude by Anthropic). Here's a breakdown of how AI was utilized:

#### Tasks Completed with AI

1. **Documentation Structure & Planning**
   - Designed the README layout following 42 curriculum requirements
   - Organized sections logically for clarity and usability
   - Ensured all mandatory requirements were addressed

2. **Content Generation**
   - Created comprehensive project descriptions
   - Wrote detailed comparison tables (VMs vs Docker, Secrets vs Env Vars, etc.)
   - Developed step-by-step installation instructions
   - Generated troubleshooting guides with common issues and solutions
   - Compiled resource lists and references

3. **Technical Explanations**
   - Explained Docker concepts and architecture decisions
   - Described design patterns and security considerations
   - Clarified technical choices with pros/cons analysis
   - Created visual diagrams and ASCII representations

4. **Code Examples & Configuration**
   - Generated sample configuration files (.env examples)
   - Provided command-line examples and usage patterns
   - Created Makefile command references
   - Wrote bash command examples for common tasks

5. **Security Documentation**
   - Outlined security best practices for the project
   - Explained credential management strategies
   - Documented prohibited patterns and proper alternatives
   - Provided security guidelines for production deployment

#### Parts of the Project NOT Generated by AI

The following were created manually:
- Actual Dockerfiles for each service
- Docker Compose configuration (docker compose.yml)
- NGINX configuration files
- WordPress initialization scripts
- Database setup scripts
- Makefile implementation
- Secret management implementation
- Actual deployment and testing

#### AI Assistance Limitations & Review

- All generated content was reviewed for accuracy and applicability to the 42 curriculum
- Technical specifications were verified against official documentation
- Security practices were checked against industry standards
- Generated examples were validated for correctness
- All links to external resources were verified

This documentation serves as a guide; actual implementation details should be reviewed and tested thoroughly before production deployment.

---

## File Guidelines

- **Dockerfiles**: Must be named `Dockerfile` (no version tags)
- **Images**: Cannot use `latest` tag; specify explicit versions
- **Base Images**: Alpine/Debian only (no other distributions)
- **Configuration**: All config files in `./conf/` directories
- **Scripts**: Utility scripts in `./tools/` directories

## 🚫 Prohibited Patterns

The following are explicitly forbidden:

```dockerfile
# ❌ DON'T: Infinite loops
CMD ["tail", "-f", "/dev/null"]
CMD ["/bin/bash"]
CMD ["sleep", "infinity"]

# ❌ DON'T: Host networking
network_mode: host

# ❌ DON'T: Deprecated link syntax
links:
  - mariadb

# ❌ DON'T: Latest tag
FROM nginx:latest
FROM wordpress:latest

# ❌ DON'T: Hardcoded passwords
ENV MYSQL_PASSWORD="password123"
```

## ✅ Proper Patterns

```dockerfile
# ✅ DO: Daemon with proper signal handling
CMD ["nginx", "-g", "daemon off;"]

# ✅ DO: Named volumes
volumes:
  wordpress_volume:
    driver: local

# ✅ DO: Environment variables from secrets
ENV MYSQL_PASSWORD_FILE=/run/secrets/db_password
RUN cat /run/secrets/db_password

# ✅ DO: Explicit versions
FROM nginx:1.25-alpine3.18
```

## Additional Development Notes

1. **Local Testing**: Use `https://login.42.fr` (browser will warn about self-signed cert)
2. **Container Logs**: Check logs frequently for debugging
3. **Volume Permissions**: Ensure host directory has proper ownership
4. **Network Debugging**: Use `docker network inspect` to verify connectivity
5. **Clean Rebuilds**: Use `make fclean && make` for complete reset

## 🔄 Restarting Services

Containers automatically restart on crash thanks to `restart_policy: always` in docker compose.yml.

To manually restart:
```bash
docker compose -f srcs/docker-compose.yml restart <service_name>
```

---

**Author**: Sveva Mazzari  
**Created**: somewhere summer 2025  
**Last Updated**: summer 2025
