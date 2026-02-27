# ==============================
# Base Image
# ==============================
FROM debian:bookworm-slim

# ==============================
# Build Arguments
# ==============================
ARG PHP_VERSION=8.2

# ==============================
# Environment
# ==============================
ENV PHP_VERSION=${PHP_VERSION} \
    DEBIAN_FRONTEND=noninteractive \
    TZ=Asia/Tehran

# ==============================
# Install Dependencies & PHP
# ==============================
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    wget \
    unzip \
    supervisor \
    nginx \
    vim \
    neovim \
    tmux \
    tzdata \
    gettext-base \
    default-mysql-client \
    && ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime && echo ${TZ} > /etc/timezone

# Add SURY PHP repo (supports PHP 5.6 - 8.5)
RUN curl -sSLo /usr/share/keyrings/deb.sury.org-php.gpg https://packages.sury.org/php/apt.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/deb.sury.org-php.gpg] https://packages.sury.org/php/ $(lsb_release -sc) main" \
    > /etc/apt/sources.list.d/php.list \
    && apt-get update

# Install PHP and extensions
#RUN apt-get install -y --no-install-recommends \
#    php${PHP_VERSION}-fpm \
#    php${PHP_VERSION}-cli \
#    php${PHP_VERSION}-common \
#    php${PHP_VERSION}-mysql \
#    php${PHP_VERSION}-mysqli \
#    php${PHP_VERSION}-pdo \
#    php${PHP_VERSION}-curl \
#    php${PHP_VERSION}-gd \
#    php${PHP_VERSION}-imagick \
#    php${PHP_VERSION}-mbstring \
#    php${PHP_VERSION}-xml \
#    php${PHP_VERSION}-zip \
#    php${PHP_VERSION}-intl \
#    php${PHP_VERSION}-bcmath \
#    php${PHP_VERSION}-soap \
#    php${PHP_VERSION}-sockets \
#    php${PHP_VERSION}-exif \
#    php${PHP_VERSION}-fileinfo \
#    php${PHP_VERSION}-json \
#    php${PHP_VERSION}-openssl \
#    php${PHP_VERSION}-zlib \
#    php${PHP_VERSION}-tokenizer \
#    php${PHP_VERSION}-ctype \
#    php${PHP_VERSION}-dom \
#    php${PHP_VERSION}-simplexml \
#    php${PHP_VERSION}-opcache \
#    php${PHP_VERSION}-redis \
#    php${PHP_VERSION}-memcached \
#    php${PHP_VERSION}-imap \
#    php${PHP_VERSION}-ldap \
#    php${PHP_VERSION}-gmp \
#    php${PHP_VERSION}-readline \
#    php${PHP_VERSION}-igbinary \
#    && apt-get clean \
#    && rm -rf /var/lib/apt/lists/*

RUN apt-get install -y --no-install-recommends \
    php${PHP_VERSION}-fpm \
    php${PHP_VERSION}-cli \
    php${PHP_VERSION}-common \
    php${PHP_VERSION}-mysql \
    php${PHP_VERSION}-curl \
    php${PHP_VERSION}-gd \
    php${PHP_VERSION}-imagick \
    php${PHP_VERSION}-mbstring \
    php${PHP_VERSION}-xml \
    php${PHP_VERSION}-zip \
    php${PHP_VERSION}-intl \
    php${PHP_VERSION}-bcmath \
    php${PHP_VERSION}-soap \
    php${PHP_VERSION}-sockets \
    php${PHP_VERSION}-opcache \
    php${PHP_VERSION}-redis \
    php${PHP_VERSION}-memcached \
    php${PHP_VERSION}-imap \
    php${PHP_VERSION}-ldap \
    php${PHP_VERSION}-gmp \
    php${PHP_VERSION}-readline \
    php${PHP_VERSION}-igbinary \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# ==============================
# IonCube Loader (offline)
# ==============================
COPY ioncube/ /tmp/ioncube/

RUN PHP_MAJOR_MINOR=$(echo ${PHP_VERSION} | grep -oP '^\d+\.\d+') \
    && IONCUBE_FILE="/tmp/ioncube/ioncube_loader_lin_${PHP_MAJOR_MINOR}.so" \
    && PHP_EXT_DIR=$(php${PHP_VERSION} -r "echo ini_get('extension_dir');") \
    && if [ -f "$IONCUBE_FILE" ]; then \
         cp "$IONCUBE_FILE" "${PHP_EXT_DIR}/ioncube_loader.so"; \
#         echo "zend_extension=ioncube_loader.so" > /etc/php/${PHP_VERSION}/mods-available/ioncube.ini; \
         echo "zend_extension=${PHP_EXT_DIR}/ioncube_loader.so" > /etc/php/${PHP_VERSION}/mods-available/ioncube.ini; \
         ln -sf /etc/php/${PHP_VERSION}/mods-available/ioncube.ini /etc/php/${PHP_VERSION}/fpm/conf.d/00-ioncube.ini; \
         ln -sf /etc/php/${PHP_VERSION}/mods-available/ioncube.ini /etc/php/${PHP_VERSION}/cli/conf.d/00-ioncube.ini; \
         echo "IonCube loader installed for PHP ${PHP_VERSION}"; \
       else \
         echo "WARNING: IonCube loader not found for PHP ${PHP_VERSION}, skipping..."; \
       fi \
    && rm -rf /tmp/ioncube/

# ==============================
# Nginx Config
# ==============================
COPY nginx/default.conf /etc/nginx/sites-available/default

# ==============================
# PHP-FPM Config
# ==============================
COPY php/custom.ini /etc/php/${PHP_VERSION}/fpm/conf.d/99-custom.ini
COPY php/custom.ini /etc/php/${PHP_VERSION}/cli/conf.d/99-custom.ini

# Fix PHP-FPM pool config
RUN PHP_FPM_POOL="/etc/php/${PHP_VERSION}/fpm/pool.d/www.conf" \
    && sed -i "s|listen = /run/php/php.*-fpm.sock|listen = 127.0.0.1:9000|g" ${PHP_FPM_POOL} \
    && sed -i "s|;listen.mode = 0660|listen.mode = 0660|g" ${PHP_FPM_POOL}

# ==============================
# Supervisor Config
# ==============================
COPY supervisor/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# ==============================
# Entrypoint Script
# ==============================
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# ==============================
# Web Root
# ==============================
RUN mkdir -p /src \
    && chown -R www-data:www-data /src \
    && mkdir -p /var/log/nginx /var/log/php /var/log/supervisor

# ==============================
# Expose & Start
# ==============================
EXPOSE 80

WORKDIR /src

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf"]
