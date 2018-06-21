ENV DOCROOT=/usr/local/apache2/htdocs

RUN mv ${DOCROOT} ${DOCROOT}.original && \
    ln -s ${DOCROOT}.original ${DOCROOT} && \
    \
    sed -i 's|\(^\s?ErrorLog\s\).*|\1"logs_error_log"|' /etc/apache2/sites-available/000-default.conf && \
    sed -i 's|\(^\s?CustomLog\s\).*|\1"logs_access_log" common|' /etc/apache2/sites-available/000-default.conf && \

HEALTHCHECK CMD /bin/nc -z 127.0.0.1 80
