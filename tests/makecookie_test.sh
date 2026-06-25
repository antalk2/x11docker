#!/usr/bin/env bash

set_up() {
    X11DOCKER_TESTING=1
    if [ -f ./x11docker ] ; then
        . ./x11docker
    else
        . .././x11docker
    fi
}


makecookie_old_fallback() {                  # bake a cookie
    #
    # - This only provides decimal digits.
    # - The length may be less than 32 (observed 28)
    #
    ## mcookie 2>/dev/null ||
    echo $RANDOM$RANDOM$RANDOM$RANDOM$RANDOM$RANDOM | cut -b1-32
}

#
# makecookie should emit 32 random hexadecimal characters
#
test_makecookie() {
    local res1 res2 res3
    res1=$(makecookie)       # probably uses mcookie
    res2=$(PATH= makecookie) # empty PATH to force fallback
    
    assert_same  32 $( printf "%s" $res1 | wc --bytes ) "mcookie  length"
    assert_same  32 $( printf "%s" $res2 | wc --bytes ) "fallback length"
    #
    assert_greater_than "0" $(printf "%s" $res1 |  tr -d 0-9 | wc --bytes) "mcookie  has hex"
    assert_greater_than "0" $(printf "%s" $res2 |  tr -d 0-9 | wc --bytes) "fallback has hex"
    #
    # assert_same  32 $( printf "%s" $res3 | wc --bytes ) "old      length"
    # assert_greater_than "0" $(printf "%s" $res3 |  tr -d 0-9 | wc --bytes) "old has hex"
}
