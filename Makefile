ALL = $(shell ls services | grep -v -e elasticsearch- -e php-) elasticsearch php
SERVICES = $(shell ls services | grep -v -e elasticsearch\$$ -e php\$$)

.PHONY: all clean $(SERVICES)

all: $(ALL)

$(SERVICES): sed
	./generate $@
	./build $@
	./tags $@ > images/$@/TAGS.md

elasticsearch: sed
	./generate elasticsearch-dockerhub
	./generate elasticsearch-elastic.co
	./build elasticsearch
	./tags elasticsearch > images/elasticsearch/TAGS.md

php: sed
	./generate php-apache
	./generate php-fpm
	./build php
	./tags php > images/php/TAGS.md

clean:
	rm -rf images

clean-all: clean
	docker container prune --force
	docker image prune --all --force

.PHONY: sed
sed:
	@sed --version >/dev/null 2>&1 || (echo "You must install gnu sed." && exit 1)
