RUN echo "discovery.type: single-node" >> /usr/share/opensearch/config/opensearch.yml

HEALTHCHECK CMD /bin/nc -z 127.0.0.1 9200
