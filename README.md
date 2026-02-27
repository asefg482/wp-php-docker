# 🐳 Docker PHP-FPM + Nginx

A complete and optimized Docker image for running **WordPress** and **Pure PHP** projects, with support for PHP 5.6 to 8.4, IonCube Loader, and all required extensions.

---

## 📋 Table of Contents

- [Features](#features)
- [Requirements](#requirements)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
- [Environment Variables](#environment-variables)
- [PHP Extensions](#php-extensions)
- [IonCube Loader](#ioncube-loader)
- [Services](#services)
- [Volumes & Data](#volumes--data)
- [Useful Commands](#useful-commands)
- [Important Notes](#important-notes)
- [Architecture](#architecture)

---

## ✨ Features

- **PHP 5.6 to 8.4** — select version via `.env`
- **Nginx + PHP-FPM** — the most optimal combination for WordPress
- **IonCube Loader** — full support for all PHP versions
- **MariaDB LTS** — stable and fast database
- **Redis** — cache and session management
- **Memcached** — fast in-memory cache
- **phpMyAdmin** — browser-based database management
- **Supervisor** — automatic service management
- **All settings from `.env`** — no need to modify config files directly
- **Traefik-ready** — prepared for reverse proxy integration
- **Debian Bookworm** — most stable base image

---

## 📦 Requirements

- [Docker](https://docs.docker.com/get-docker/) version 20+
- [Docker Compose](https://docs.docker.com/compose/install/) version 2+

> **Note for Mac users (Apple Silicon):** Since IonCube is only available for x86-64 architecture, the image must be built with `platform: linux/amd64`. This setting is already configured in `docker-compose.yml`.

---

## 📁 Project Structure

```
project/
├── Dockerfile                      ← Image definition
├── docker-compose.yml              ← Service definitions
├── .env                            ← All configuration
├── entrypoint.sh                   ← Startup script (runs on each container start)
│
├── ioncube/                        ← IonCube Loader .so files
│   ├── ioncube_loader_lin_5.6.so
│   ├── ioncube_loader_lin_7.0.so
│   ├── ioncube_loader_lin_7.1.so
│   ├── ioncube_loader_lin_7.2.so
│   ├── ioncube_loader_lin_7.3.so
│   ├── ioncube_loader_lin_7.4.so
│   ├── ioncube_loader_lin_8.0.so
│   ├── ioncube_loader_lin_8.1.so
│   ├── ioncube_loader_lin_8.2.so
│   ├── ioncube_loader_lin_8.3.so
│   └── ioncube_loader_lin_8.4.so
│
├── nginx/
│   └── default.conf                ← Nginx configuration
│
├── php/
│   └── custom.ini                  ← PHP configuration
│
├── supervisor/
│   └── supervisord.conf            ← Supervisor configuration
│
├── src/                            ← Your project goes here
│
└── data/                           ← Persistent data (auto-created)
    ├── redis/                      ← Redis data
    ├── mariadb/                    ← MariaDB data
    └── logs/
        ├── nginx/                  ← Nginx logs
        ├── php/                    ← PHP logs
        └── supervisor/             ← Supervisor logs
```

---

## 🚀 Getting Started

### Step 1: Download IonCube Loaders

Download the IonCube loader files from the official website:

```
https://www.ioncube.com/loaders.php
```

Download the **Linux (64-bit)** version:
- File: `ioncube_loaders_lin_x86-64.tar.gz`
- Extract and place the `.so` files inside the `ioncube/` directory

> **Important:** Only download files **without** the `_ts` suffix (Non-Thread Safe version for PHP-FPM).

### Step 2: Configure .env

Open the `.env` file and configure your settings:

```env
PHP_VERSION=8.2          # Desired PHP version
DB_NAME=wordpress        # Database name
DB_USER=wpuser           # Database user
DB_PASSWORD=yourpassword # Database password
```

### Step 3: Build and Run

```bash
# First time or after Dockerfile changes
docker compose up -d --build

# After .env changes only
docker compose restart
```

### Step 4: Place Your Project

Put your project files inside the `src/` directory:

```bash
cp -r /path/to/your/project/* ./src/
```

---

## ⚙️ Environment Variables

```env
# ==============================
# PHP Version (5.6 - 8.4)
# ==============================
PHP_VERSION=8.2

# ==============================
# PHP Limits
# ==============================
POST_MAX_SIZE=240M
UPLOAD_MAX_SIZE=240M
TIMEOUT=30
MEMORY_LIMIT=512M

# ==============================
# PHP-FPM Pool
# ==============================
PM_MAX_CHILDREN=64
PM_START_SERVERS=8
PM_MIN_SPARE_SERVERS=8
PM_MAX_SPARE_SERVERS=16
PM_MAX_SPAWN_RATE=32
PM_MAX_REQUESTS=1000

# ==============================
# PHP Security
# ==============================
PHP_SECURITY_DISABLED_FUNCTIONS=;
PHP_SECURITY_ENABLE_DL=Off
PHP_SECURITY_EXPOSE_PHP=Off
PHP_SECURITY_ERROR_REPORTING=E_ALL & ~E_DEPRECATED & ~E_STRICT
PHP_SECURITY_DISPLAY_ERRORS=Off
PHP_SECURITY_DISPLAY_STARTUP_ERRORS=Off

# ==============================
# OPcache
# ==============================
OPCACHE_ENABLE=1
OPCACHE_ENABLE_CLI=0
OPCACHE_JIT=tracing
OPCACHE_JIT_BUFFER_SIZE=256M
OPCACHE_VALIDATE_TIMESTAMPS=1
OPCACHE_REVALIDATE_FREQ=60
OPCACHE_MAX_ACCELERATED_FILES=32000
OPCACHE_MEMORY_CONSUMPTION=256
OPCACHE_INTERNED_STRINGS_BUFFER=16
OPCACHE_SAVE_COMMENTS=1
OPCACHE_FAST_SHUTDOWN=1

# ==============================
# Timezone
# ==============================
TZ=Asia/Tehran

# ==============================
# Nginx
# ==============================
NGINX_PORT=80

# ==============================
# MariaDB
# ==============================
DB_ROOT_PASSWORD=strongrootpassword
DB_NAME=wordpress
DB_USER=wpuser
DB_PASSWORD=strongpassword

# ==============================
# Redis
# ==============================
REDIS_PASSWORD=strongpassword
REDIS_MAX_MEMORY=256mb
REDIS_MAX_MEMORY_POLICY=allkeys-lru

# ==============================
# Memcached
# ==============================
MEMCACHED_MEMORY=128
MEMCACHED_MAX_CONNECTIONS=1024

# ==============================
# phpMyAdmin
# ==============================
PMA_PORT=8080
PMA_ABSOLUTE_URI=
```

### Build Image

```bash
docker rmi wp-docker-php-nginx --force
docker buildx build --platform linux/amd64 -t wp-docker-php-nginx . 
```


### Key Parameters

| Parameter | Description |
|-----------|-------------|
| `PHP_VERSION` | PHP version (5.6–8.4) — requires rebuild |
| `MEMORY_LIMIT` | Max memory per PHP process |
| `PM_MAX_CHILDREN` | Max number of PHP-FPM workers |
| `OPCACHE_JIT` | Enable JIT compiler (PHP 8+ only) |
| `REDIS_MAX_MEMORY_POLICY` | Redis eviction policy when memory is full |
| `PMA_ABSOLUTE_URI` | Full phpMyAdmin URL when behind a reverse proxy |

---

## 🧩 PHP Extensions

All of the following extensions are installed and enabled:

| Extension | Purpose |
|-----------|---------|
| `mysqli`, `pdo_mysql` | MySQL/MariaDB connection |
| `curl` | HTTP requests |
| `gd`, `imagick` | Image processing |
| `mbstring` | Multibyte string support |
| `xml`, `dom`, `simplexml` | XML processing |
| `zip` | Archive handling |
| `intl` | Internationalization |
| `bcmath` | Arbitrary precision math |
| `soap` | SOAP web services |
| `sockets` | Socket communication |
| `opcache` | PHP bytecode caching |
| `redis` | Redis connection |
| `memcached` | Memcached connection |
| `imap` | IMAP protocol |
| `ldap` | LDAP authentication |
| `gmp` | Large number arithmetic |
| `igbinary` | Optimized serialization |
| `ioncube` | Running encoded PHP files |

---

## 🔐 IonCube Loader

### Downloading the Files

Download the **Linux (64-bit)** version from [ioncube.com/loaders.php](https://www.ioncube.com/loaders.php).

Required files:

```
ioncube_loader_lin_5.6.so
ioncube_loader_lin_7.0.so
ioncube_loader_lin_7.1.so
ioncube_loader_lin_7.2.so
ioncube_loader_lin_7.3.so
ioncube_loader_lin_7.4.so
ioncube_loader_lin_8.0.so
ioncube_loader_lin_8.1.so
ioncube_loader_lin_8.2.so
ioncube_loader_lin_8.3.so
ioncube_loader_lin_8.4.so
```

### Thread Safe vs Non-Thread Safe

| Type | Suffix | Use Case |
|------|--------|----------|
| Non-Thread Safe | no `_ts` | **PHP-FPM** ✅ |
| Thread Safe | `_ts` | Apache mod_php ❌ |

Only download the version **without** `_ts`.

### Verify Installation

```bash
docker exec -it php-nginx-8.2 php -m | grep -i ioncube
```

Expected output:
```
ionCube Loader
the ionCube PHP Loader
```

---

## 🛠️ Services

### PHP-FPM + Nginx

- Project files go in `/src`
- Nginx listens on the port defined by `NGINX_PORT` (default: 80)
- PHP-FPM listens on `127.0.0.1:9000` (internal only)
- Reverse proxy and SSL are managed by the user

### MariaDB

Connect from inside the container:
```bash
mysql -h mariadb -u wpuser -p
```

WordPress `wp-config.php` settings:
```php
define('DB_HOST', 'mariadb');
define('DB_NAME', 'wordpress');
define('DB_USER', 'wpuser');
define('DB_PASSWORD', 'yourpassword');
```

### Redis

Connection details (from inside the container):
```
Host: redis
Port: 6379
Password: (value of REDIS_PASSWORD)
```

To use Redis with WordPress, install the [Redis Object Cache](https://wordpress.org/plugins/redis-cache/) plugin.

### Memcached

Connection details (from inside the container):
```
Host: memcached
Port: 11211
```

### phpMyAdmin

Available on port `PMA_PORT` (default: 8080):
```
http://localhost:8080
```

To enable with Traefik:
```yaml
labels:
  - "traefik.enable=true"
  - "traefik.http.routers.pma.rule=Host(`pma.yourdomain.com`)"
```

---

## 💾 Volumes & Data

All data is stored alongside your project:

| Host Path | Contents |
|-----------|---------|
| `./src` | Your PHP/WordPress project |
| `./data/mariadb` | Database files |
| `./data/redis` | Redis persistent data |
| `./data/logs/nginx` | Nginx logs |
| `./data/logs/php` | PHP error logs |
| `./data/logs/supervisor` | Supervisor logs |

---

## 🧰 Useful Commands

### Container Management

```bash
# Start services
docker compose up -d

# Stop services
docker compose down

# Restart without rebuild
docker compose restart

# Rebuild and start
docker compose up -d --build

# Full rebuild (no cache)
docker compose build --no-cache
docker compose up -d
```

### Accessing the Container

```bash
# Open shell
docker exec -it php-nginx-8.2 bash

# Check PHP version
docker exec -it php-nginx-8.2 php -v

# List loaded extensions
docker exec -it php-nginx-8.2 php -m

# Verify IonCube
docker exec -it php-nginx-8.2 php -m | grep -i ioncube
```

### Log Monitoring

```bash
# Container logs
docker logs -f php-nginx-8.2

# Nginx error log
tail -f ./data/logs/nginx/error.log

# PHP error log
tail -f ./data/logs/php/error.log
```

### Database Access

```bash
# From inside the php-nginx container
docker exec -it php-nginx-8.2 mysql -h mariadb -u wpuser -p

# Directly from the mariadb container
docker exec -it mariadb mariadb -u root -p
```

### Switching PHP Version

```bash
# 1. Update PHP_VERSION in .env
PHP_VERSION=7.4

# 2. Rebuild
docker compose down
docker compose build --no-cache
docker compose up -d
```

---

## ⚠️ Important Notes

### .htaccess Support

This image uses **Nginx**, which does **not** support `.htaccess` files. Any `.htaccess` rules must be converted to `nginx/default.conf` directives.

WordPress permalinks are already configured in Nginx:
```nginx
location / {
    try_files $uri $uri/ /index.php?$args;
}
```

To convert `.htaccess` rules to Nginx syntax, you can use [winginx.com](https://winginx.com/en/htaccess).

### OPcache JIT

OPcache JIT is only supported from **PHP 8.0** onwards. For PHP 5.6–7.4, JIT-related settings are automatically ignored.

### Redis & Memcached

These are PHP **extensions** only — they allow PHP to communicate with Redis/Memcached servers. The actual Redis and Memcached services are already included in `docker-compose.yml`.

### Mac Apple Silicon (ARM64)

IonCube Loader is not available for ARM64 architecture. The image is built with `platform: linux/amd64` and runs via Rosetta on Apple Silicon Macs. On Linux x86-64 servers, there are no issues and no performance penalty.

### Production Security

For production environments, it is strongly recommended to:
- Set strong, unique passwords in `.env`
- Add `.env` to `.gitignore` — never commit secrets to version control
- Restrict phpMyAdmin access via Traefik with an authentication middleware
- Never expose database ports (3306) publicly
- Keep `PHP_SECURITY_EXPOSE_PHP=Off` (already the default)

---

## 🏗️ Architecture

```
                    ┌─────────────────────────────────────┐
                    │           Docker Network             │
                    │                                      │
Internet ──────────►│  Nginx (port 80)                     │
(via Traefik)       │       │                              │
                    │       ▼                              │
                    │  PHP-FPM (127.0.0.1:9000)            │
                    │       │                              │
                    │  ┌────┴──────────────────────────┐   │
                    │  │             /src               │   │
                    │  │    Your PHP / WordPress App    │   │
                    │  └───────────────────────────────┘   │
                    │                                      │
                    │  MariaDB   ◄─────────────────────┐   │
                    │  Redis     ◄─────────────────────┤   │
                    │  Memcached ◄─────────────────────┘   │
                    │                                      │
                    │  phpMyAdmin (port 8080)               │
                    └─────────────────────────────────────┘
```

- **Reverse Proxy & SSL** — managed by the user (Traefik recommended)
- **Domain configuration** — managed by the user
- **Supervisor** — automatically restarts Nginx and PHP-FPM if they crash

---

## 📝 License

MIT License

---

## 🤝 Contributing

Pull requests and issues are welcome!