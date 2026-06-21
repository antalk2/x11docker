
.PHONY: test all


all:


test:
	make -C tests test

run1:
	./x11docker

run2:
	../x11docker-firefox
