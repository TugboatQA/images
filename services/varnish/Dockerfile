RUN curl -L https://packagecloud.io/varnishcache/varnish60lts/gpgkey | sudo apt-key add - && \
  echo 'deb https://packagecloud.io/varnishcache/varnish60lts/ubuntu/ bionic main' >> /etc/apt/sources.list.d/varnishcache_varnish60lts.list && \
  echo 'deb-src https://packagecloud.io/varnishcache/varnish60lts/ubuntu/ bionic main' >> /etc/apt/sources.list.d/varnishcache_varnish60lts.list && \
  apt update && \
  apt install -y \
  varnish \
  && rm -rf /var/cache/apt

# This is the common entrypoint script used by official images.
COPY files/usr/local/bin/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

# Check the Varnish administration interface
HEALTHCHECK CMD /bin/nc -z 127.0.0.1 6082
