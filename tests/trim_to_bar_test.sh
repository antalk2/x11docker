#!/usr/bin/env bash

set_up() {
 X11DOCKER_TESTING=1
 . ./x11docker
}

test_trim_to_bar() {
     local x y
     x="$(trim_to_bar \
         "|abc
          | def
          |  ghi")"
     y="$(printf "abc\n def\n  ghi")"
     assert_same "$y" "$x" 
}

 
test_trim_to_mark() {
    local x y
    x="$(trim_to_mark \
        "|abc
         :d
         :e
         :f
         |ghi")"
    y="$(printf "abcdef\nghi")"
    assert_same "$y" "$x" 
}

