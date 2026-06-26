#!/bin/bash

wincmd() {
    MSYS2_ARG_CONV_EXCL='*' cmd.exe /C "${@//&/^&}" | rmcr
}

f(){
    echo  "${@//&/^&}"
}

f a b '&' c '&&' d
# prints: a b ^& c ^&^& d

# f a b 'M&M'

# https://stackoverflow.com/questions/1327431/how-do-i-escape-ampersands-in-batch-files#1327476
#
# How do I escape ampersands in batch files?
#
# A: & is used to separate commands. Therefore you can use ^ to escape the &.
#
