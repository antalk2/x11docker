#!/usr/bin/env bash

set_up() {
 X11DOCKER_TESTING=1
 . ./x11docker
}

test_escapestring() {
    # fixed : characters not to be escaped
    #         Note: uses character ranges, but that is OK here.
    #
    local fixed='a-zA-Z0-9,._+@=:/-'
    local escaped
    escaped="$(escapestring "${fixed}")"
    assert_same "$fixed" "$escaped"
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

test_createmountopt() {
    local res
    local File="/tmp/xxx yyy"
    # File must exist
    touch "${File}"
    #
    res="$(createmountopt mount  "$File" "ro" )"
    assert_same '--mount type=bind,source=/tmp/xxx\ yyy,target=/tmp/xxx\ yyy,readonly' "${res}"
    #
    res="$(createmountopt device  "$File" "ro" )"
    assert_same '--device /tmp/xxx\ yyy:ro' "${res}"
    #
    res="$(createmountopt volume  "$File" "ro" )"
    assert_same '--volume /tmp/xxx\ yyy:/tmp/xxx\ yyy:ro' "${res}"
    #
    unlink "${File}"
}
