#!/bin/bash

# shellcheck disable=SC2034
X11DOCKER_TESTING=1
# shellcheck disable=SC1091
. ../../x11docker

Myps=ps

# Override error()
error(){
    echo "ERROR: $*" >&2
}



test_ppid_success() {
    local pid="$1"
    local expected_ppid="$2"
    local res exitcode
    local FAILED=""
    res="$( get_ppid "${pid}" )"
    exitcode=$?
    if [ "$exitcode" != "0" ] ; then
        echo "FAIL: exitcode $exitcode is not 0"
        FAILED=yes
    fi
    if [ ! -z "$expected_ppid"  ] ; then
        if [ "$res" != "$expected_ppid" ] ; then
            echo "FAIL: (res '$res') != (expected_ppid '$expected_ppid')"
            FAILED=yes
        fi
    fi
    if [ -z "$FAILED" ] ; then
        echo "SUCCESS: ppid of $pid is $res"
    fi
}

test_ppid_error() {
    local pid="$1"
    local res exitcode
    local FAILED=""
    res="$( get_ppid "${pid}" 2>/dev/null )"
    exitcode=$?
    if [ "$exitcode" != "2" ] ; then
        echo "FAIL: exitcode $exitcode is not 2. Reported ppid is $res"
        FAILED=yes
    fi
    if [ -z "$FAILED" ] ; then
        echo "SUCCESS: get_ppid reports error for pid '$pid'"
    fi
}

test_ppid_notfound() {
    local pid="$1"
    local res exitcode
    local FAILED=""
    res="$( get_ppid "${pid}" 2>/dev/null )"
    exitcode=$?
    if [ "$exitcode" != "1" ] ; then
        echo "FAIL: exitcode $exitcode is not 1. Reported ppid is '$res'"
        FAILED=yes
    fi
    if [ ! -z "$res" ] ; then
        echo "FAIL: ppid '$res' is not empty"
        FAILED=yes
    fi
    if [ -z "$FAILED" ] ; then
        echo "SUCCESS: get_ppid reports empty ppid ('$res') for pid '$pid'"
    fi
}


test_ppid_success 1 0
test_ppid_success 2
test_ppid_success 3
test_ppid_success $$

test_ppid_error nosuchpid
test_ppid_error PID

test_ppid_notfound 99999999999999



echo

echo "Test check_parent_sshd"


check_parent_sshd "$$"
echo "check_parent_sshd returned $?"

