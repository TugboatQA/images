RUN apt update && \
  apt install -y \
  varnish \
  varnish-modules \
  && rm -rf /var/cache/apt

# Check the Varnish administration interface
HEALTHCHECK CMD /bin/nc -z 127.0.0.1 6082
