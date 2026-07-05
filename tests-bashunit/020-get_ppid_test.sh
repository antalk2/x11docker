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
    export Myps
    error() {
        echo "ERROR: $*" >&2
    }
    #
    #
    local x expected
    x="$(get_ppid 1)"
    expected="0"
    assert_same "$expected" "$x"  "get_ppid 1"
    #
    f1(){
        ( get_ppid noshuchpid )
    }
    assert_exec "f1"  --exit 2 --stderr-contains "ERROR:" --stdout ""
    #
    f2(){
        ( get_ppid  ) # missing arg
    }
    assert_exec "f2"  --exit 2 --stderr-contains "ERROR:" --stdout ""
    #
    f3(){
        ( get_ppid 999999999999 ) # very large arg, Likely no hit
    }
    assert_exec "f3"  --exit 1 --stderr "" --stdout ""
    #
    f4(){
        ( get_ppid 0 ) # no hit
    }
    assert_exec "f4"  --exit 1 --stderr "" --stdout ""
}
