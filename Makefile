
.PHONY: test all TAGS shellcheck


all:


test: lib/bashunit
	lib/bashunit tests/ --fail-on-risky # -vvv

test-verbose: lib/bashunit
	lib/bashunit tests/  -vvv

run1:
	./x11docker

run2:
	../x11docker-firefox


#
TAGS:
	./etags-bash.sh x11docker


lib/bashunit:
	if test -e install.sh ; then rm install.sh ; fi
	wget https://bashunit.com/install.sh
	bash install.sh
	-rm install.sh


shellcheck:
	shellcheck --shell=bash x11docker
