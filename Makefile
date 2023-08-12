ALL = $(shell ls services | grep -v -e elasticsearch- -e php- -e percona) elasticsearch php
SERVICES = $(shell ls services | grep -v -e elasticsearch\$$ -e php\$$ -e percona)
export DOCKER_BUILDKIT ?= 1
# If you would like to push to docker hub after docker build, and then remove
# the image, you may set this environment variable to 1.
export push_and_rm ?= 0

.PHONY: all clean $(ALL) php-nginx
.PARALLEL: $(ALL)

all: $(ALL)

$(SERVICES):
	./generate $@
	./build $@
	./tags $@

elasticsearch:
	./generate elasticsearch-dockerhub
	./generate elasticsearch-elastic.co
	./build elasticsearch
	./tags elasticsearch > images/elasticsearch/TAGS.md

php: php-nginx
	./generate php-apache
	./generate php-fpm
	./build php
	./tags php

clean:
	rm -rf images

clean-all: clean
	docker container prune --force
	docker image prune --all --force
