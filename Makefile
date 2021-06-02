ALL = $(shell ls services | grep -v -e elasticsearch- -e php- -e ruby-) elasticsearch php ruby
SERVICES = $(shell ls services | grep -v -e elasticsearch\$$ -e php\$$ -e ruby\$$)

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

ruby:
	./generate ruby-debian
	./generate ruby-alpine
	./build ruby
	./tags ruby > images/ruby/TAGS.md

clean:
	rm -rf images

clean-all: clean
	docker container prune --force
	docker image prune --all --force
