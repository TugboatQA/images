COPY files/mysql/tugboat.cnf /etc/mysql/conf.d/tugboat.cnf

ENV MYSQL_ALLOW_EMPTY_PASSWORD=true \
    MYSQL_USER=tugboat \
    MYSQL_PASSWORD=tugboat \
    MYSQL_HOST=127.0.0.1 \
    MYSQL_ROOT_HOST=%

HEALTHCHECK CMD /usr/bin/mysqladmin ping
