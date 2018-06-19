ENV DOCROOT=/usr/local/apache2/htdocs

RUN mv ${DOCROOT} ${DOCROOT}.original && \
    ln -s ${DOCROOT}.original ${DOCROOT}

HEALTHCHECK CMD /bin/nc -z 127.0.0.1 80
