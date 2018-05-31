SERVICES = $(shell ls services)

.PHONY: all clean $(SERVICES)

all: $(SERVICES)

$(SERVICES):
	./generate $@
	find ./images/$@ -name Dockerfile -exec ./build {} \;

clean:
	rm -rf images