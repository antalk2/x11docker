#!/usr/bin/env bash

set_up() {
    X11DOCKER_TESTING=1
    . ./x11docker
    #    declare_variables
}


test_get_ppid() {
    #
    if [ "${Myps:-empty}" = "empty" ] ; then
        # exit 1
        Myps=$(command -v ps || command -v psproc)
        echo "Myps is empty, set to 'Myps'"
    fi
    #
    #
    local x expected
    x="$(xget_ppid 1)"
    expected="0"
    assert_same "$expected" "$x"  "get_ppid 1"
    #
    x="$(xget_ppid noshuchpid)"
    expected=""
    assert_same "$expected" "$x"  "get_ppid noshuchpid"
    #
    x="$(xget_ppid)"
    expected=""
    assert_same "$expected" "$x" "missing-arg"
    #
    assert_exec "xget_ppid" --exit 1 --stdout ""
}
