ALL = $(shell ls services | grep -v -e elasticsearch- -e php-)
SERVICES = $(shell ls services | grep -v -e elasticsearch\$$ -e php\$$)

.PHONY: all clean $(SERVICES)

all: $(ALL)

$(SERVICES):
	./generate $@
	./build $@

elasticsearch:
	./generate elasticsearch-dockerhub
	./generate elasticsearch-elastic.co
	./build elasticsearch

php:
	./generate php-apache
	./generate php-fpm
	./build php

clean:
	rm -rf images

clean-all: clean
	docker container prune --force
	docker image prune --all --force
