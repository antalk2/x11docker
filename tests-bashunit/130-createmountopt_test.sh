#!/usr/bin/env bash

set_up() {
 X11DOCKER_TESTING=1
 . ./x11docker
}

#
# Test createmountopt()
#
test_createmountopt() {
    local res
    local File="/tmp/xxx yyy"
    # File must exist
    touch "${File}"
    #
    res="$(createmountopt_mount ro "$File" )"
    assert_same '--mount type=bind,source=/tmp/xxx\ yyy,target=/tmp/xxx\ yyy,readonly' "${res}"
    #
    res="$(createmountopt_device "ro" "$File"  )"
    assert_same '--device /tmp/xxx\ yyy:ro' "${res}"
    #
    res="$(createmountopt volume "ro" "$File"  )"
    assert_same '--volume /tmp/xxx\ yyy:/tmp/xxx\ yyy:ro' "${res}"
    #
    unlink "${File}"
    #
    # If the file does not exist, stdout is empty and exitcode is 1
    assert_exec 'createmountopt_mount "ro" "$File" ' --exit 1 --stdout "" --stderr ""
    #
    # The following result in message on stderr
    #
    local Debugmode=yes
    local Verbose=not-yes
    local FDstderr=2
    assert_exec 'createmountopt_mount ro  "$File"' --exit 1 --stdout "" \
                --stderr-contains "DEBUGNOTE"
    #
    assert_exec 'createmountopt_mount  "ro" "$File"' --exit 1 --stdout "" \
                --stderr-contains "createmountopt_mount(): ERROR: File not found:"
}
