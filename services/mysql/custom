EXPOSE 3306

COPY files/mysql/tugboat.cnf /etc/mysql/conf.d/tugboat.cnf

ENV MYSQL_ALLOW_EMPTY_PASSWORD=true \
    MYSQL_USER=tugboat \
    MYSQL_PASSWORD=tugboat \
    MYSQL_HOST=127.0.0.1 \
    MYSQL_ROOT_HOST=%

# mysql-5.5 does not get installed in the default path
ENV PATH=$PATH:/usr/local/mysql/bin:/usr/local/mysql/scripts

HEALTHCHECK CMD /usr/bin/mysqladmin ping
