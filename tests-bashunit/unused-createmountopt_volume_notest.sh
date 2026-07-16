#!/usr/bin/env bash

set_up() {
 X11DOCKER_TESTING=1
 . ./x11docker
}



# createmountopt_volume is not used.
#
# Function: createmountopt_volume
#
# Brief: Create option for docker to mount a volume, check if it exists
#
# Usage: createmountopt_volume Rw File
#
#
# stdout: "--volume ${eFile}:${eFile}$Rw"
#
createmountopt_volume() {
    #             volume -> "--volume ${eFile}:${eFile}$Rw"
    #
    # $1  Rw:     {ro|rw} (Was: ro|readonly, optional)
    # $2  File:   file or device to share
    #             If does not exist, emit nothing and return 1
    #
    local File Rw
    Rw="${1:-}"
    File="${2:-}"

    if [ ! -e "$File" ] ; then
        debugnote "createmountopt_volume(): ERROR: File not found: '$File'"
        return 1
    fi
    #
    #case "$Rw" in
    #    "ro"|"readonly")  Rw=":ro" ;;
    #    *)                Rw=""    ;;
    #esac
    #
    local eFile
    eFile="$(escapestring "$File")"
    #
    # https://docs.docker.com/engine/storage/volumes/
    # docker run --mount type=volume,src=<volume-name>,dst=<mount-path>
    # docker run --volume <volume-name>:<mount-path>
    # docker run --volume [<volume-name>:]<mount-path>[:opts]
    #   Here opts is a comma-separated list of options, like ro.
    #   The colon just separates it from <mount-path>
    case "$Rw" in
        "ro"|"readonly")
            # Rw=":ro"
            echo "--volume ${eFile}:${eFile}:ro"
            ;;
        "rw")
            # Rw=""
            echo "--volume ${eFile}:${eFile}"
            ;;
        *) error  "createmountopt_volume(): ERROR: Rw '$Rw' is not in {rw|ro} "  ;;
    esac
}

test_createmountopt_volume() {
    local res
    local File="/tmp/xxx yyy"
    # File must exist
    touch "${File}"
    #
    res="$( createmountopt_volume "ro" "$File"  )"
    assert_same '--volume /tmp/xxx\ yyy:/tmp/xxx\ yyy:ro' "${res}"
    #
    unlink "${File}"
    #
    # If the file does not exist, stdout is empty and exitcode is 1
    assert_exec 'createmountopt_volume "ro" "$File" ' --exit 1 --stdout "" --stderr ""
    #
}
