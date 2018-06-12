ALL = $(shell ls services | grep -v -e elasticsearch- -e php-)
SERVICES = $(shell ls services | grep -v -e php\$$ -e elasticsearch\$$)

.PHONY: all clean $(SERVICES)

all: $(ALL)

$(SERVICES):
	./generate $@
	./build $@

elasticsearch:
	./generate elasticsearch-dockerhub
	./generate elasticsearch-elastic.co
	echo "# Supported tags" > images/elasticsearch/README.md
	echo "" >> images/elasticsearch/README.md
	find images/elasticsearch -name TAGS -r | sort | xargs cat | sed 's/ /\`, \`/g' | sed 's/^/\* \`/g' | sed 's/$$/\`/g' >> images/elasticsearch/README.md
	echo "" >> images/elasticsearch/README.md
	cat services/elasticsearch/README.md >> images/elasticsearch/README.md
	./build elasticsearch

php:
	./generate php-apache
	./generate php-fpm
	echo "# Supported tags" > images/php/README.md
	echo "" >> images/php/README.md
	find images/php -name TAGS | sort -r | xargs cat | sed 's/ /\`, \`/g' | sed 's/^/\* \`/g' | sed 's/$$/\`/g' >> images/php/README.md
	echo "" >> images/php/README.md
	cat services/php/README.md >> images/php/README.md
	./build php

clean:
	rm -rf images

clean-all: clean
	docker container prune --force
	docker image prune --all --force
