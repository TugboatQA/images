ENV COMPOSER_NO_INTERACTION=1 \
    COMPOSER_DISCARD_CHANGES=1 \
    COMPOSER_ALLOW_SUPERUSER=1 \
    DOCROOT=/var/www/html

RUN apt-get install -y libfreetype6-dev libjpeg62-turbo-dev libmcrypt-dev libpng-dev && \
    (apt-get install -y mysql-client || apt-get install -y mariadb-client) && \
    \
    (docker-php-ext-configure gd --with-freetype-dir=/usr/include/ && \
        docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ || \
        docker-php-ext-configure gd --with-jpeg-dir=/usr/include/) && \
    docker-php-ext-install -j$(nproc) gd iconv pdo_mysql && \
    \
    (pecl install xdebug || pecl install xdebug-2.5.5 || pecl install xdebug-2.7.0beta1) && \
    bash -c "(pecl install mcrypt <<< '' || pecl install mcrypt-1.0.1 <<< '' || docker-php-ext-install mcrypt || /bin/true)" && \
    (docker-php-ext-enable mcrypt || /bin/true) && \
    \
    php -r "copy('https://raw.githubusercontent.com/composer/getcomposer.org/master/web/installer', 'composer-setup.php');" && \
    php composer-setup.php && \
    php -r "unlink('composer-setup.php');" && \
    \
    mv composer.phar /usr/local/bin/composer && \
    mkdir -p /etc/service/apache && \
    echo "umask 0002" >> /etc/apache2/envvars && \
    \
    mv ${DOCROOT} ${DOCROOT}.original && \
    ln -s ${DOCROOT}.original ${DOCROOT}

COPY files/apache.runit /etc/service/apache/run
COPY files/000-default.conf /etc/apache2/sites-available/000-default.conf
COPY files/tugboat.ini /usr/local/etc/php/conf.d/tugboat.ini

HEALTHCHECK CMD /bin/nc -z 127.0.0.1 80
