#!/usr/bin/env bash

set_up() {
    X11DOCKER_TESTING=1
    . ./x11docker
    #    declare_variables
    #
    if [ "${Myps:-empty}" = "empty" ] ; then
        # exit 1
        Myps=$(command -v ps || command -v psproc)
        echo "Note: Myps was empty, set to '${Myps}'"
    fi
    export Myps
    error() {
        echo "ERROR: $*" >&2
    }
}


test_get_ppid_1() {
    local x expected
    x="$(get_ppid 1)"
    expected="0"
    assert_same "$expected" "$x"  "get_ppid 1"
    #
}

test_get_ppid_nosuchpid() {
    #
    f1() {
        ( get_ppid noshuchpid )
    }
    assert_exec "f1"  --exit 2 --stderr-contains "ERROR:" --stdout ""
    #                        ^          ^^
}

test_get_ppid_nosuchpid_v2() {
    #
    #
    #
    local x expected
    x="$(get_ppid noshuchpid)"
    expected=""
    assert_same "$expected" "$x"  "get_ppid noshuchpid"
    #
}


test_get_ppid_missing_arg() {
    #
    f2() {
        ( get_ppid  ) # missing arg
    }
    assert_exec "f2"  --exit 2 --stderr-contains "ERROR:" --stdout ""
    #
}

test_get_ppid_999999999999() {
    #
    f3(){
        ( get_ppid 999999999999 ) # very large arg, Likely no hit
    }
    assert_exec "f3"  --exit 1 --stderr "" --stdout ""
    #
}

test_get_ppid_0() {
    #
    f4(){
        ( get_ppid 0 ) # no hit
    }
    assert_exec "f4"  --exit 1 --stderr "" --stdout ""
    #
}
