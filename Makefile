SERVICES = $(shell echo services/*/ | cut -d/ -f2)

.PHONY: all clean $(SERVICES)

all: $(SERVICES)

$(SERVICES):
	./generate $@
	find ./images/$@ -name Dockerfile -exec ./build {} \;

clean:
	rm -rf images