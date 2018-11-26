ALL = $(shell ls services | grep -v -e elasticsearch- -e mysql- -e percona- -e php-)
SERVICES = $(shell ls services | grep -v -e elasticsearch\$$ -e mysql\$$ -e percona\$$ -e php\$$)

.PHONY: all clean $(SERVICES)

all: $(ALL)

$(SERVICES):
	./generate $@
	./build $@

elasticsearch:
	./generate elasticsearch-dockerhub
	./generate elasticsearch-elastic.co
	./build elasticsearch

mysql:
	./generate mysql-5
	./generate mysql-8
	./build mysql

percona:
	./generate percona-5
	./generate percona-8
	./build percona

php:
	./generate php-apache
	./generate php-fpm
	./build php

clean:
	rm -rf images

clean-all: clean
	docker container prune --force
	docker image prune --all --force
