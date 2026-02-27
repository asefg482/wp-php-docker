#!/bin/bash
set -e

# ==============================
# Load .env if exists
# ==============================
if [ -f /var/www/.env ]; then
    export $(grep -v '^#' /var/www/.env | xargs)
fi

# ==============================
# Set defaults
# ==============================
PHP_VERSION=${PHP_VERSION:-8.2}
POST_MAX_SIZE=${POST_MAX_SIZE:-240M}
UPLOAD_MAX_SIZE=${UPLOAD_MAX_SIZE:-240M}
TIMEOUT=${TIMEOUT:-30}
MEMORY_LIMIT=${MEMORY_LIMIT:-512M}
TZ=${TZ:-Asia/Tehran}
NGINX_PORT=${NGINX_PORT:-80}

PM_MAX_CHILDREN=${PM_MAX_CHILDREN:-64}
PM_START_SERVERS=${PM_START_SERVERS:-8}
PM_MIN_SPARE_SERVERS=${PM_MIN_SPARE_SERVERS:-8}
PM_MAX_SPARE_SERVERS=${PM_MAX_SPARE_SERVERS:-16}
PM_MAX_SPAWN_RATE=${PM_MAX_SPAWN_RATE:-32}
PM_MAX_REQUESTS=${PM_MAX_REQUESTS:-1000}

PHP_SECURITY_DISABLED_FUNCTIONS=${PHP_SECURITY_DISABLED_FUNCTIONS:-;}
PHP_SECURITY_ENABLE_DL=${PHP_SECURITY_ENABLE_DL:-Off}
PHP_SECURITY_EXPOSE_PHP=${PHP_SECURITY_EXPOSE_PHP:-Off}
PHP_SECURITY_ERROR_REPORTING=${PHP_SECURITY_ERROR_REPORTING:-"E_ALL & ~E_DEPRECATED & ~E_STRICT"}
PHP_SECURITY_DISPLAY_ERRORS=${PHP_SECURITY_DISPLAY_ERRORS:-Off}
PHP_SECURITY_DISPLAY_STARTUP_ERRORS=${PHP_SECURITY_DISPLAY_STARTUP_ERRORS:-Off}

OPCACHE_ENABLE=${OPCACHE_ENABLE:-1}
OPCACHE_ENABLE_CLI=${OPCACHE_ENABLE_CLI:-0}
OPCACHE_JIT=${OPCACHE_JIT:-tracing}
OPCACHE_JIT_BUFFER_SIZE=${OPCACHE_JIT_BUFFER_SIZE:-256M}
OPCACHE_VALIDATE_TIMESTAMPS=${OPCACHE_VALIDATE_TIMESTAMPS:-1}
OPCACHE_REVALIDATE_FREQ=${OPCACHE_REVALIDATE_FREQ:-60}
OPCACHE_MAX_ACCELERATED_FILES=${OPCACHE_MAX_ACCELERATED_FILES:-32000}
OPCACHE_MEMORY_CONSUMPTION=${OPCACHE_MEMORY_CONSUMPTION:-256}
OPCACHE_INTERNED_STRINGS_BUFFER=${OPCACHE_INTERNED_STRINGS_BUFFER:-16}
OPCACHE_SAVE_COMMENTS=${OPCACHE_SAVE_COMMENTS:-1}
OPCACHE_FAST_SHUTDOWN=${OPCACHE_FAST_SHUTDOWN:-1}

# ==============================
# Export all for PHP ini
# ==============================
export POST_MAX_SIZE UPLOAD_MAX_SIZE TIMEOUT MEMORY_LIMIT TZ
export PHP_SECURITY_DISABLED_FUNCTIONS PHP_SECURITY_ENABLE_DL PHP_SECURITY_EXPOSE_PHP
export PHP_SECURITY_ERROR_REPORTING PHP_SECURITY_DISPLAY_ERRORS PHP_SECURITY_DISPLAY_STARTUP_ERRORS
export OPCACHE_ENABLE OPCACHE_ENABLE_CLI OPCACHE_JIT OPCACHE_JIT_BUFFER_SIZE
export OPCACHE_VALIDATE_TIMESTAMPS OPCACHE_REVALIDATE_FREQ OPCACHE_MAX_ACCELERATED_FILES
export OPCACHE_MEMORY_CONSUMPTION OPCACHE_INTERNED_STRINGS_BUFFER OPCACHE_SAVE_COMMENTS OPCACHE_FAST_SHUTDOWN
export PHP_VERSION

# ==============================
# Apply envsubst to PHP ini
# ==============================
envsubst < /etc/php/${PHP_VERSION}/fpm/conf.d/99-custom.ini > /tmp/99-custom.ini
cp /tmp/99-custom.ini /etc/php/${PHP_VERSION}/fpm/conf.d/99-custom.ini
cp /tmp/99-custom.ini /etc/php/${PHP_VERSION}/cli/conf.d/99-custom.ini

# ==============================
# Update PHP-FPM pool settings
# ==============================
POOL_CONF="/etc/php/${PHP_VERSION}/fpm/pool.d/www.conf"

sed -i "s|^pm.max_children = .*|pm.max_children = ${PM_MAX_CHILDREN}|" ${POOL_CONF}
sed -i "s|^pm.start_servers = .*|pm.start_servers = ${PM_START_SERVERS}|" ${POOL_CONF}
sed -i "s|^pm.min_spare_servers = .*|pm.min_spare_servers = ${PM_MIN_SPARE_SERVERS}|" ${POOL_CONF}
sed -i "s|^pm.max_spare_servers = .*|pm.max_spare_servers = ${PM_MAX_SPARE_SERVERS}|" ${POOL_CONF}
sed -i "s|^;pm.max_spawn_rate = .*|pm.max_spawn_rate = ${PM_MAX_SPAWN_RATE}|" ${POOL_CONF}
sed -i "s|^pm.max_requests = .*|pm.max_requests = ${PM_MAX_REQUESTS}|" ${POOL_CONF}

# ==============================
# Update Nginx port
# ==============================
sed -i "s|listen 80 |listen ${NGINX_PORT} |g" /etc/nginx/sites-available/default
sed -i "s|listen \[::]:80 |listen [::]:${NGINX_PORT} |g" /etc/nginx/sites-available/default

# ==============================
# Update PHP-FPM binary path in supervisor
# ==============================
sed -i "s|%(ENV_PHP_VERSION)s|${PHP_VERSION}|g" /etc/supervisor/conf.d/supervisord.conf

# ==============================
# Permissions
# ==============================
chown -R www-data:www-data /src
mkdir -p /var/log/php /var/log/nginx /var/log/supervisor
touch /var/log/php/error.log
chown www-data:www-data /var/log/php/error.log

# ==============================
# Timezone
# ==============================
ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime && echo ${TZ} > /etc/timezone

echo "==============================="
echo " PHP Version : ${PHP_VERSION}"
echo " Memory Limit: ${MEMORY_LIMIT}"
echo " Timezone    : ${TZ}"
echo " Nginx Port  : ${NGINX_PORT}"
echo "==============================="

exec "$@"
