COPY --chmod=644 files/mysql/tugboat.cnf /etc/mysql/conf.d/tugboat.cnf

ENV MYSQL_ALLOW_EMPTY_PASSWORD=true \
    MYSQL_USER=tugboat \
    MYSQL_PASSWORD=tugboat \
    MYSQL_DATABASE=tugboat \
    MYSQL_HOST=localhost \
    MYSQL_ROOT_HOST=localhost

HEALTHCHECK CMD /bin/nc -z 127.0.0.1 3306
