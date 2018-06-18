ENV COMPOSER_NO_INTERACTION=1 \
    DOCROOT=/var/www/html

RUN php -r "copy('https://raw.githubusercontent.com/composer/getcomposer.org/master/web/installer', 'composer-setup.php');" && \
    php composer-setup.php && \
    php -r "unlink('composer-setup.php');" && \
    mv composer.phar /usr/local/bin/composer && \
    \
    (pecl install xdebug || pecl install xdebug-2.5.5) && docker-php-ext-enable xdebug && \
    \
    mkdir -p /etc/service/apache && \
    echo "umask 0002" >> /etc/apache2/envvars && \
    sed -i 's|\(^\sErrorLog\s\).*|\1/proc/self/fd/2|' /etc/apache2/sites-available/000-default.conf && \
    sed -i 's|\(^\sCustomLog\s\).*|\1/proc/self/fd/1 combined|' /etc/apache2/sites-available/000-default.conf && \
    \
    mv ${DOCROOT} ${DOCROOT}.original && \
    ln -s ${DOCROOT}.original ${DOCROOT}

COPY files/apache.runit /etc/service/apache/run
HEALTHCHECK CMD /bin/nc -z 127.0.0.1 80
