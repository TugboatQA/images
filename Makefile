ALL = $(shell ls services | grep -v -e elasticsearch- -e php- -e percona) elasticsearch php php-fpm-nginx
SERVICES = $(shell ls services | grep -v -e elasticsearch\$$ -e php\$$ -e percona)
export DOCKER_BUILDKIT ?= 1
# If you would like to push to docker hub after docker build, and then remove
# the image, you may set this environment variable to 1.
export push_and_rm ?= 0

.PHONY: all clean $(ALL)
.PARALLEL: $(ALL)

all: $(ALL)

php-nginx: php-fpm-nginx
	.PHONY

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
