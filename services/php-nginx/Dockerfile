ENV COMPOSER_NO_INTERACTION=1 \
    COMPOSER_DISCARD_CHANGES=1 \
    COMPOSER_ALLOW_SUPERUSER=1 \
    DOCROOT=/usr/share/nginx/html

RUN apt-get install -y libfreetype6-dev libjpeg62-turbo-dev libmcrypt-dev libpng-dev libwebp-dev nginx && \
    (apt-get install -y mysql-client || apt-get install -y mariadb-client) && \
    docker-php-ext-configure gd --with-jpeg --with-freetype --with-webp && \
    docker-php-ext-install -j$(nproc) gd iconv pdo_mysql && \
    \
    (((pecl install xdebug || pecl install xdebug-2.5.5 || pecl install xdebug-2.8.0beta2) && \
    bash -c "(pecl install mcrypt <<< '' || pecl install mcrypt-1.0.1 <<< '' || docker-php-ext-install mcrypt || /bin/true)" && \
    (docker-php-ext-enable mcrypt || /bin/true)) || /bin/true) && \
    php -r "copy('https://raw.githubusercontent.com/composer/getcomposer.org/master/web/installer', 'composer-setup.php');" && \
    php composer-setup.php && \
    php -r "unlink('composer-setup.php');" && \
    mv composer.phar /usr/local/bin/composer && \
    mv ${DOCROOT} ${DOCROOT}.original && \
    ln -s ${DOCROOT}.original ${DOCROOT} && \
    rm /etc/nginx/sites-enabled/default

# Configure php-fpm to run as a service.
COPY files/service/php-fpm/run /etc/service/php-fpm/run
COPY files/service/nginx/run /etc/service/nginx/run
COPY files/tugboat.ini /usr/local/etc/php/conf.d/tugboat.ini
COPY files/nginx.conf /etc/nginx/nginx.conf
COPY files/sites-enabled/* /etc/nginx/sites-enabled/

HEALTHCHECK CMD /bin/nc -z 127.0.0.1 80
