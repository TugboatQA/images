ENV DOCROOT=/usr/local/apache2/htdocs

RUN mv ${DOCROOT} ${DOCROOT}.original && \
    ln -s ${DOCROOT}.original ${DOCROOT} && \
    \
    sed -i 's|\(^\s?ErrorLog\s\).*|\1"logs_error_log"|' /usr/local/apache2/conf/httpd.conf && \
    sed -i 's|\(^\s?CustomLog\s\).*|\1"logs_access_log" common|' /usr/local/apache2/conf/httpd.conf

HEALTHCHECK CMD /bin/nc -z 127.0.0.1 80
