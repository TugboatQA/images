COPY files/mysql/tugboat.cnf /etc/my.cnf.d/tugboat.cnf

RUN cd /var/lib/mysql && mysqld --initialize --user=mysql

ENV MYSQL_ALLOW_EMPTY_PASSWORD=true \
    MYSQL_USER=tugboat \
    MYSQL_PASSWORD=tugboat \
    MYSQL_DATABASE=tugboat \
    MYSQL_HOST=localhost \
    MYSQL_ROOT_HOST=localhost

HEALTHCHECK CMD /usr/bin/true &>/dev/null </dev/tcp/127.0.0.1/3306
