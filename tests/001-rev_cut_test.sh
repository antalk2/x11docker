#!/usr/bin/env bash

set_up() {
 X11DOCKER_TESTING=1
 . ./x11docker
}

test_rev_cut() {
    # rev_cut counts fields from the end of line
    assert_same "def"                    "$( echo abcdef | rev_cut -c1-3 )"
    
    # rev_cut works with multiple lines
    assert_same "$( printf "def\nDEF" )" "$( printf "abddef\nABCDEF" | rev_cut -c1-3 | rev_cut -c1-3 )"
}
