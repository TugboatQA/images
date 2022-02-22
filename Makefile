ALL = $(shell ls services | grep -v -e elasticsearch- -e php- -e percona) elasticsearch php
SERVICES = $(shell ls services | grep -v -e elasticsearch\$$ -e php\$$ -e percona)

.PHONY: all clean $(SERVICES)

all: $(ALL)

$(SERVICES):
	./generate $@
	./build $@
	./tags $@ > images/$@/TAGS.md

elasticsearch:
	./generate elasticsearch-dockerhub
	./generate elasticsearch-elastic.co
	./build elasticsearch
	./tags elasticsearch > images/elasticsearch/TAGS.md

php:
	./generate php-apache
	./generate php-fpm
	./build php
	./tags php > images/php/TAGS.md

clean:
	rm -rf images

clean-all: clean
	docker container prune --force
	docker image prune --all --force
