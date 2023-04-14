# Debian images by default disable apt caching, so turn it on until we finish
# the build.
RUN mv /etc/apt/apt.conf.d/docker-clean /etc/apt/docker-clean-disabled

# sharing=locked prevents concurrent builds from accessing this cache at the
# same time. To improve build performance, we ensure we only run apt related
# commands in this layer.
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && \
    apt-get install -y libfreetype6-dev libjpeg62-turbo-dev libmcrypt-dev libpng-dev libwebp-dev && \
    (apt-get install -y mysql-client || apt-get install -y mariadb-client)

ENV COMPOSER_NO_INTERACTION=1 \
    COMPOSER_DISCARD_CHANGES=1 \
    COMPOSER_ALLOW_SUPERUSER=1

RUN docker-php-ext-configure gd --with-jpeg --with-freetype --with-webp && \
    docker-php-ext-install -j$(nproc) gd iconv pdo_mysql && \
    \
    (((pecl install xdebug || pecl install xdebug-2.5.5 || pecl install xdebug-2.8.0beta2) && \
    bash -c "(pecl install mcrypt <<< '' || pecl install mcrypt-1.0.1 <<< '' || docker-php-ext-install mcrypt || /bin/true)" && \
    (docker-php-ext-enable mcrypt || /bin/true)) || /bin/true) && \
    \
    php -r "copy('https://raw.githubusercontent.com/composer/getcomposer.org/master/web/installer', 'composer-setup.php');" && \
    php composer-setup.php && \
    php -r "unlink('composer-setup.php');" && \
    mv composer.phar /usr/local/bin/composer

# Configure php-fpm to run as a service.
COPY files/service/php-fpm/run /etc/service/php-fpm/run

COPY files/tugboat.ini /usr/local/etc/php/conf.d/tugboat.ini

# Now layer on nginx on top.
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && \
    apt-get install -y nginx

# We're done with apt so disable caching again for the final image.
RUN mv /etc/apt/docker-clean-disabled /etc/apt/apt.conf.d/docker-clean

ENV DOCROOT=/usr/share/nginx/html

RUN mv ${DOCROOT} ${DOCROOT}.original && \
    ln -s ${DOCROOT}.original ${DOCROOT}

COPY files/nginx.conf /etc/nginx/nginx.conf
COPY files/sites-enabled/* /etc/nginx/sites-enabled/
RUN rm /etc/nginx/sites-enabled/default

EXPOSE 80

# Create an index.php file for local testing.
RUN mkdir -p /var/lib/tugboat/web
COPY files/index.php /var/lib/tugboat/web/index.php

HEALTHCHECK CMD /bin/nc -z 127.0.0.1 80
