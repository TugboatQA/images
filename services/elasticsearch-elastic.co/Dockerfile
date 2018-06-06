ENV PATH /usr/share/elasticsearch/bin:$PATH
ENV discovery.type single-node
EXPOSE 9200 9300
HEALTHCHECK CMD /bin/nc -z 127.0.0.1 9200
