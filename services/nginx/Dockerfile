ENV DOCROOT=/usr/share/nginx/html

RUN mv ${DOCROOT} ${DOCROOT}.original && \
    ln -s ${DOCROOT}.original ${DOCROOT}

HEALTHCHECK CMD /bin/nc -z 127.0.0.1 80
