#!/bin/bash

#
# 1. Bash does allow inner functions, but they are globally visible.
# 2. Parenthesis, like   `( commands )`, runs commands in a subshell.
#

xouter() {
    echo "in xouter"
    local a
    local b=2
    xinner() (
        echo "in xinner"
        c="$1"
        #
        echo  " inner a: $a"
        echo  " inner b: $b"
        echo  " inner c: $c"
        #
        a="CHANGED"
    )
    xinner "cc"
    local res
    res=$(xinner "cc")
    printf "res=%s" "$res"
}

xouter

echo -e "\nIs xinner global?"

xinner
