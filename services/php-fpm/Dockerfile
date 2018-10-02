ENV COMPOSER_NO_INTERACTION=1

RUN apt-get install -y libfreetype6-dev libjpeg62-turbo-dev libmcrypt-dev libpng-dev mysql-client && \
    \
    docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ && \
    docker-php-ext-install -j$(nproc) gd iconv pdo_mysql && \
    (pecl install xdebug || pecl install xdebug-2.5.5 || pecl install xdebug-xdebug-2.7.0beta1) && \
    bash -c "(pecl install mcrypt <<< '' || pecl install mcrypt-1.0.1 <<< '' || docker-php-ext-install mcrypt)" && \
    docker-php-ext-enable xdebug mcrypt && \
    \
    php -r "copy('https://raw.githubusercontent.com/composer/getcomposer.org/master/web/installer', 'composer-setup.php');" && \
    php composer-setup.php && \
    php -r "unlink('composer-setup.php');" && \
    mv composer.phar /usr/local/bin/composer

COPY files/tugboat.ini /usr/local/etc/php/conf.d/sendmail.ini

HEALTHCHECK CMD /bin/nc -z 127.0.0.1 9000
