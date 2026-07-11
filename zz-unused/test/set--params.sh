#!/bin/sh


#
# Q: Which positional parameters does "set -- a b c" set?
# A: The functions parameters, not the scripts
#

f() {
    set -- a b c d
    #
    echo "Within f"
    echo "${#}"
    echo "${@}"

}

f
echo "Outside f"
echo "${#}"
echo "${@}"
