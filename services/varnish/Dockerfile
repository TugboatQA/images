RUN apt update && \
  apt install -y \
  varnish \
  varnish-modules \
  && rm -rf /var/cache/apt

# This is the common entrypoint script used by official images.
COPY files/usr/local/bin/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

# Check the Varnish administration interface
HEALTHCHECK CMD /bin/nc -z 127.0.0.1 6082
