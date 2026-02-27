# 🐳 Docker PHP-FPM + Nginx

یک Docker image کامل و بهینه برای اجرای پروژه‌های **WordPress** و **Pure PHP** با پشتیبانی از PHP 5.6 تا 8.4، IonCube Loader، و تمام extension های مورد نیاز.

---

## 📋 فهرست مطالب

- [ویژگی‌ها](#ویژگیها)
- [پیش‌نیازها](#پیشنیازها)
- [ساختار پروژه](#ساختار-پروژه)
- [نصب و راه‌اندازی](#نصب-و-راهاندازی)
- [تنظیمات .env](#تنظیمات-env)
- [PHP Extensions](#php-extensions)
- [IonCube Loader](#ioncube-loader)
- [سرویس‌ها](#سرویسها)
- [Volumes و دیتا](#volumes-و-دیتا)
- [دستورات مفید](#دستورات-مفید)
- [نکات مهم](#نکات-مهم)
- [معماری](#معماری)

---

## ✨ ویژگی‌ها

- **PHP 5.6 تا 8.4** - انتخاب نسخه از طریق `.env`
- **Nginx + PHP-FPM** - بهینه‌ترین ترکیب برای WordPress
- **IonCube Loader** - پشتیبانی کامل برای همه نسخه‌های PHP
- **MariaDB LTS** - دیتابیس پایدار و سریع
- **Redis** - cache و session management
- **Memcached** - cache سریع در حافظه
- **phpMyAdmin** - مدیریت دیتابیس از طریق مرورگر
- **Supervisor** - مدیریت خودکار سرویس‌ها
- **تمام تنظیمات از `.env`** - بدون نیاز به تغییر فایل‌های config
- **پشتیبانی از Traefik** - آماده برای reverse proxy
- **Debian Bookworm** - پایدارترین base image

---

## 📦 پیش‌نیازها

- [Docker](https://docs.docker.com/get-docker/) نسخه 20+
- [Docker Compose](https://docs.docker.com/compose/install/) نسخه 2+

> **توجه برای کاربران Mac (Apple Silicon):** به دلیل اینکه IonCube فقط برای معماری x86-64 موجود است، image باید با `platform: linux/amd64` build شود. این تنظیم از قبل در `docker-compose.yml` اعمال شده است.

---

## 📁 ساختار پروژه

```
project/
├── Dockerfile                      ← تعریف image
├── docker-compose.yml              ← تعریف سرویس‌ها
├── .env                            ← تمام تنظیمات
├── entrypoint.sh                   ← اسکریپت اجرا هنگام start
│
├── ioncube/                        ← فایل‌های IonCube Loader
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
│   └── default.conf                ← تنظیمات Nginx
│
├── php/
│   └── custom.ini                  ← تنظیمات PHP
│
├── supervisor/
│   └── supervisord.conf            ← تنظیمات Supervisor
│
├── src/                            ← ← پروژه شما اینجا قرار می‌گیرد
│
└── data/                           ← داده‌ها (خودکار ساخته می‌شود)
    ├── redis/                      ← داده‌های Redis
    ├── mariadb/                    ← داده‌های MariaDB
    └── logs/
        ├── nginx/                  ← لاگ‌های Nginx
        ├── php/                    ← لاگ‌های PHP
        └── supervisor/             ← لاگ‌های Supervisor
```

---

## 🚀 نصب و راه‌اندازی

### مرحله ۱: دانلود IonCube Loaders

فایل‌های IonCube را از سایت رسمی دانلود کنید:

```
https://www.ioncube.com/loaders.php
```

نسخه **Linux (64-bit)** را دانلود کنید:
- فایل: `ioncube_loaders_lin_x86-64.tar.gz`
- فایل‌های `.so` مربوطه را در پوشه `ioncube/` قرار دهید

> **توجه:** فقط فایل‌های بدون پسوند `_ts` را دانلود کنید (نسخه Non-Thread Safe برای PHP-FPM).

### مرحله ۲: تنظیم .env

فایل `.env` را باز کنید و تنظیمات مورد نیاز را انجام دهید:

```env
PHP_VERSION=8.2          # نسخه PHP مورد نظر
DB_NAME=wordpress        # نام دیتابیس
DB_USER=wpuser           # نام کاربر دیتابیس
DB_PASSWORD=yourpassword # پسورد دیتابیس
```

### مرحله ۳: Build و اجرا

```bash
# اولین بار یا بعد از تغییر Dockerfile
docker compose up -d --build

# بعد از تغییر فقط .env
docker compose restart
```

### مرحله ۴: قرار دادن پروژه

فایل‌های پروژه خود را در پوشه `src/` قرار دهید:

```bash
cp -r /path/to/your/project/* ./src/
```

---

## ⚙️ تنظیمات .env

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

### ساختن image

```bash
docker rmi wp-docker-php-nginx --force
docker buildx build --platform linux/amd64 -t wp-docker-php-nginx . 
```

### توضیح پارامترهای مهم

| پارامتر | توضیح |
|---------|-------|
| `PHP_VERSION` | نسخه PHP (5.6 تا 8.4) - نیاز به rebuild دارد |
| `MEMORY_LIMIT` | حداکثر حافظه هر پروسه PHP |
| `PM_MAX_CHILDREN` | حداکثر تعداد worker های PHP-FPM |
| `OPCACHE_JIT` | فعال‌سازی JIT compiler (فقط PHP 8+) |
| `REDIS_MAX_MEMORY_POLICY` | سیاست پاک‌سازی Redis هنگام پر شدن حافظه |
| `PMA_ABSOLUTE_URI` | آدرس کامل phpMyAdmin پشت reverse proxy |

---

## 🧩 PHP Extensions

تمام extension های زیر نصب و فعال هستند:

| Extension | کاربرد |
|-----------|--------|
| `mysqli`, `pdo_mysql` | اتصال به MySQL/MariaDB |
| `curl` | درخواست‌های HTTP |
| `gd`, `imagick` | پردازش تصویر |
| `mbstring` | رشته‌های چندبایتی (فارسی و عربی) |
| `xml`, `dom`, `simplexml` | پردازش XML |
| `zip` | فایل‌های فشرده |
| `intl` | بین‌المللی‌سازی |
| `bcmath` | محاسبات دقیق |
| `soap` | وب سرویس‌های SOAP |
| `sockets` | ارتباط socket |
| `opcache` | کش کد PHP |
| `redis` | اتصال به Redis |
| `memcached` | اتصال به Memcached |
| `imap` | پروتکل IMAP |
| `ldap` | احراز هویت LDAP |
| `gmp` | محاسبات اعداد بزرگ |
| `igbinary` | سریال‌سازی بهینه |
| `ioncube` | اجرای فایل‌های رمزنگاری شده |

---

## 🔐 IonCube Loader

### دانلود فایل‌ها

از [ioncube.com/loaders.php](https://www.ioncube.com/loaders.php) نسخه **Linux (64-bit)** را دانلود کنید.

فایل‌های مورد نیاز:

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

### تفاوت نسخه‌ها

| نوع | پسوند | کاربرد |
|-----|-------|--------|
| Non-Thread Safe | بدون `_ts` | **PHP-FPM** ✅ |
| Thread Safe | `_ts` | Apache mod_php ❌ |

فقط نسخه **بدون** `_ts` را دانلود کنید.

### بررسی نصب

```bash
docker exec -it php-nginx-8.2 php -m | grep -i ioncube
```

خروجی موفق:
```
ionCube Loader
the ionCube PHP Loader
```

---

## 🛠️ سرویس‌ها

### PHP-FPM + Nginx

- پروژه در `/src` قرار می‌گیرد
- Nginx روی پورت تعریف شده در `NGINX_PORT` (پیشفرض: 80)
- PHP-FPM روی `127.0.0.1:9000` (داخلی)
- Reverse proxy و SSL به عهده کاربر است

### MariaDB

اتصال از داخل container:
```bash
mysql -h mariadb -u wpuser -p
```

اتصال از WordPress:
```php
define('DB_HOST', 'mariadb');
define('DB_NAME', 'wordpress');
define('DB_USER', 'wpuser');
define('DB_PASSWORD', 'yourpassword');
```

### Redis

اتصال از داخل container:
```
Host: redis
Port: 6379
Password: (مقدار REDIS_PASSWORD)
```

### Memcached

اتصال از داخل container:
```
Host: memcached
Port: 11211
```

### phpMyAdmin

در دسترس روی پورت `PMA_PORT` (پیشفرض: 8080):
```
http://localhost:8080
```

برای فعال کردن با Traefik:
```yaml
labels:
  - "traefik.enable=true"
  - "traefik.http.routers.pma.rule=Host(`pma.yourdomain.com`)"
```

---

## 💾 Volumes و دیتا

تمام داده‌ها در کنار پروژه ذخیره می‌شوند:

| مسیر هاست | محتوا |
|-----------|-------|
| `./src` | پروژه PHP/WordPress |
| `./data/mariadb` | داده‌های دیتابیس |
| `./data/redis` | داده‌های Redis (persistent) |
| `./data/logs/nginx` | لاگ‌های Nginx |
| `./data/logs/php` | لاگ‌های PHP |
| `./data/logs/supervisor` | لاگ‌های Supervisor |

---

## 🧰 دستورات مفید

### مدیریت Container

```bash
# اجرا
docker compose up -d

# توقف
docker compose down

# restart بدون rebuild
docker compose restart

# rebuild و اجرا
docker compose up -d --build

# rebuild کامل (بدون cache)
docker compose build --no-cache
docker compose up -d
```

### ورود به Container

```bash
# shell
docker exec -it php-nginx-8.2 bash

# بررسی PHP
docker exec -it php-nginx-8.2 php -v
docker exec -it php-nginx-8.2 php -m

# بررسی IonCube
docker exec -it php-nginx-8.2 php -m | grep -i ioncube
```

### مدیریت لاگ‌ها

```bash
# لاگ کلی container
docker logs -f php-nginx-8.2

# لاگ Nginx
tail -f ./data/logs/nginx/error.log

# لاگ PHP
tail -f ./data/logs/php/error.log
```

### اتصال به دیتابیس

```bash
# از داخل container php
docker exec -it php-nginx-8.2 mysql -h mariadb -u wpuser -p

# مستقیم از container mariadb
docker exec -it mariadb mariadb -u root -p
```

### تغییر نسخه PHP

```bash
# در .env تغییر دهید
PHP_VERSION=7.4

# rebuild کنید
docker compose down
docker compose build --no-cache
docker compose up -d
```

---

## ⚠️ نکات مهم

### .htaccess

این image از **Nginx** استفاده می‌کند و فایل `.htaccess` پشتیبانی **نمی‌شود**. قوانین `.htaccess` باید به `nginx/default.conf` تبدیل شوند.

WordPress permalinks از قبل در Nginx تنظیم شده:
```nginx
location / {
    try_files $uri $uri/ /index.php?$args;
}
```

برای تبدیل `.htaccess` به Nginx می‌توانید از [winginx.com](https://winginx.com/en/htaccess) استفاده کنید.

### OPcache و JIT

OPcache JIT فقط از **PHP 8.0** به بالا پشتیبانی می‌کند. برای PHP 5.6 تا 7.4 این تنظیمات نادیده گرفته می‌شوند.

### Redis و Memcached

این سرویس‌ها فقط **extension** هستند. برای استفاده از Redis در WordPress باید پلاگینی مثل [Redis Object Cache](https://wordpress.org/plugins/redis-cache/) نصب کنید.

### Mac Apple Silicon (ARM64)

IonCube Loader برای ARM64 وجود ندارد. Image با `platform: linux/amd64` build می‌شود و از طریق Rosetta روی Mac اجرا می‌گردد. روی سرورهای Linux x86-64 مشکلی نیست.

### امنیت Production

برای محیط production توصیه می‌شود:
- پسوردهای قوی در `.env` تنظیم کنید
- فایل `.env` را در `.gitignore` قرار دهید
- phpMyAdmin را فقط از طریق Traefik با احراز هویت در دسترس قرار دهید
- پورت‌های دیتابیس را expose نکنید

---

## 🏗️ معماری

```
                    ┌─────────────────────────────────┐
                    │         Docker Network           │
                    │                                  │
Internet ──────────►│  Nginx (port 80)                 │
(via Traefik)       │       │                          │
                    │       ▼                          │
                    │  PHP-FPM (127.0.0.1:9000)        │
                    │       │                          │
                    │  ┌────┴────────────────────┐     │
                    │  │         /src             │     │
                    │  │   پروژه PHP/WordPress    │     │
                    │  └─────────────────────────┘     │
                    │                                  │
                    │  MariaDB ◄──────────────────┐    │
                    │  Redis   ◄──────────────────┤    │
                    │  Memcached ◄────────────────┘    │
                    │                                  │
                    │  phpMyAdmin (port 8080)           │
                    └─────────────────────────────────┘
```

- **Reverse Proxy و SSL**: به عهده کاربر (Traefik پیشنهاد می‌شود)
- **دامنه**: به عهده کاربر
- **Supervisor**: مدیریت Nginx و PHP-FPM به صورت خودکار

---

## 📝 لایسنس

MIT License

---

## 🤝 مشارکت

Pull Request و Issue خوش‌آمد است!