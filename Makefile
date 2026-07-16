
.PHONY: test all TAGS shellcheck


all:



run1:
	./x11docker

run2:
	../x11docker-firefox


#
TAGS:
	./etags-bash.sh x11docker



shellcheck:
	shellcheck --shell=bash x11docker



test: ./lib/bashunit
	./lib/bashunit tests-bashunit --fail-on-risky  # -vvv

test-filtered: ./lib/bashunit
	./lib/bashunit tests-bashunit --fail-on-risky --filter num  # -vvv


test-verbose: ./lib/bashunit
	./lib/bashunit tests-bashunit  -vvv



./lib/bashunit:
	cd lib && if test -e install.sh ; then rm install.sh ; fi
	cd lib && wget https://bashunit.com/install.sh
	cd lib && bash install.sh .
	cd lib && rm install.sh

