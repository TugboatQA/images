COPY files/docker-entirypoint-initdb.d /docker-entrypoint-initdb.d

ENV POSTGRES_DB=tugboat

HEALTHCHECK CMD /bin/nc -z 127.0.0.1 5432
