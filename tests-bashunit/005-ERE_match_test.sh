#!/usr/bin/env bash

if false ; then
    # Test the copy in x11docker
    #
    # ERE_match is not used in x11docker
    #
    # Reason: The inerpretation of ERE in @code{[[ "$str" =~ $ERE ]]}
    #         differs too much from ERE in @code{grep -E} and @code{sed -E},
    #         thus a compatible non-bash implementation is not likely.
    #
    #
    set_up() {
        X11DOCKER_TESTING=1
        . ./x11docker
    }
else
    # Test local copy
    # ------------------------------------------------------------
    #
    # Function: ERE_match str ERE
    #
    # return: 0 if str matches ERE
    #         1 if does not
    #         2 on error
    #
    # Compatible_shells: bash
    #
    ERE_match() {
        local str="${1}"
        local ERE="${2}"
        [[ "$str" =~ $ERE ]]
    }
    # ------------------------------------------------------------
fi

test_ERE_match_001a() {
    ERE_match '8' '[0123456789]' 
    assert_exit_code 0 # matches
}

test_ERE_match_001b() {
    ERE_match '128' '([0-9]+)'
    assert_exit_code 0
}

test_ERE_match_001c() {
    ERE_match '8x128' '^[0-9]+x[0-9]+$'
    assert_exit_code 0 #
}


test_ERE_match_002() {
    ERE_match 'a1920x2000' '^[0-9]+x[0-9]+$'
    assert_exit_code 1 # does not match
}

