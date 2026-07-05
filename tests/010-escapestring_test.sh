#!/usr/bin/env bash

set_up() {
 X11DOCKER_TESTING=1
 . ./x11docker
}

#
# Test the function escapestring()
#
test_escapestring() {
    # fixed_characters : characters not to be escaped. Note: uses character
    #         ranges, but that is OK here, it contains a
    #         representative set
    #
    local fixed_characters='a-zA-Z0-9,._+@=:/-'
    local escaped
    escaped="$( escapestring "${fixed_characters}" )"
    assert_same "$fixed_characters" "$escaped"  "Fixed_characters_are_not_modified"
    #
    # single_quote is an error
    #
    local sq="a'b"
    assert_exec "(escapestring \"$sq\")" --exit 0 --stdout "" \
                --stderr-contains "x11docker ERROR: escapestring(): x11docker cannot escape char ' in :"
    #
    # All other characters are escaped using a backslash (except single_quote)
    #
    assert_same  '\ '     "$(escapestring ' '     )" "space"
    assert_same  '\	' "$(escapestring "	" )" "tab"
    assert_same  '\\t'    "$(escapestring '\t'    )" "backslash-t"
    assert_same  '\\t'    "$(escapestring "\t"    )" "backslash-t"
   
}
