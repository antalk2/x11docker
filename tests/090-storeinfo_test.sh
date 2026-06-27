#!/usr/bin/env bash

set_up() {
 X11DOCKER_TESTING=1
 . ./x11docker
}

test_storeinfo_1() {

    Storeinfofile="storeinfo.tmp"
    #
    # Start with an empty Storeinfofile
    #
    if [ -e "$Storeinfofile" ] ; then rm "$Storeinfofile" ; fi
    touch "$Storeinfofile"
    #
    # xxx is not there
    assert_exec "storeinfo_test_sh xxx" --exit 1 --stdout ""
    #
    assert_exec "storeinfo_add_kv_sh 'xxx=bbb'" --exit 0  --stdout ""
    #
    # xxx is there now
    assert_exec "storeinfo_test_sh xxx" --exit 0 --stdout ""
    #
    local res
    res="$(storeinfo_dump_sh xxx)"
    assert_same "bbb" "$res"
    #
    unlink "$Storeinfofile"
}
