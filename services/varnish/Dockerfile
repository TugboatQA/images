RUN apt update && \
  apt install -y \
  varnish \
  varnish-modules \
  && rm -rf /var/cache/apt

HEALTHCHECK CMD /bin/nc -z 127.0.0.1 80
