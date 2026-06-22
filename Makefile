
.PHONY: test all TAGS


all:


test:
	make -C tests test

run1:
	./x11docker

run2:
	../x11docker-firefox


#
TAGS:
	./etags-bash.sh x11docker

