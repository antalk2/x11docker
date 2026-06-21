#!/usr/bin/env bash


#
# Testing with https://github.com/kward/shunit2
#

testOne() {
    assertEquals "Jaj1" "a" "a"
    # assertEquals "Jaj2" "a" "b"
}

# assertEquals   [message] expected actual
# assertContains [message] container content

#
# declare -A res
# capture res cmd args
#
# Runs `cmd args`, captures exitCode, stderr and stdout to
#       res[exitCode] res[stdout] and res[stderr]
#
capture() {
    # $1 should name an associative array
    declare -n result="$1"
    shift
    #
    # Run cmd and capture its exitCode, stdout, stderr
    #
    local tmpfile1="$(mktemp -t file_1_XXXXXX)"
    local tmpfile2="$(mktemp -t file_2_XXXXXX)"
    "${@}"  2>"$tmpfile2" 1>"$tmpfile1"
    result[exitCode]="$?"
    result[stdout]="$(< "$tmpfile1")"
    result[stderr]="$(< "$tmpfile2")"
    unlink "$tmpfile1"
    unlink "$tmpfile2"
    return 0
}

f1() {
    echo "Good $1"
    echo "Bad $2" >&2
    return 13
}

test_capture() {
    declare -A res
    capture res f1 aha jaj
    assertEquals 13         "${res[exitCode]}"
    assertEquals "Good aha" "${res[stdout]}"
    assertEquals "Bad jaj"  "${res[stderr]}"
}

#
# test convertpath_split_Readwritemode()
#
test_convertpath_split_Readwritemode() {
    local Readwritemode_out
    local Path_out
    local Path
    #
    #
    export FDstderr=2 # warning needs it
    #
    Path="/some/path:ro"
    declare -A res
    capture res convertpath_split_Readwritemode Readwritemode_out Path_out "$Path"
    #
    assertEquals ":ro"         "${Readwritemode_out}"
    assertEquals "/some/path"  "${Path_out}"
    #
    assertEquals 0             "${res[exitCode]}"
    assertEquals ""            "${res[stdout]}"
    assertEquals ""            "${res[stderr]}"
    #
    #
    #
    Path="/some/path:rw"
    declare -A res
    capture res convertpath_split_Readwritemode Readwritemode_out Path_out "$Path"
    #
    assertEquals ":rw"         "${Readwritemode_out}"
    assertEquals "/some/path"  "${Path_out}"
    #
    assertEquals 0             "${res[exitCode]}"
    assertEquals ""            "${res[stdout]}"
    assertEquals ""            "${res[stderr]}"
    #
    #
    # Suffix ":.." exists, but is not :ro or :rw
    #
    # Currently (1) Readwritemode_out is set to "rw",
    #           (2) Suffix is removed from Path_out.
    #           (3) A warning is emitted
    #           (4) return 1
    #           
    #
    Path="/some/path:rr"
    Readwritemode_out='UNCHANGED'
    #
    # WRONG: $(stuff) executes stuff in a subshell: outpout values are lost
    # stderr="$(convertpath_split_Readwritemode Readwritemode_out Path_out "$Path" 2>&1 1>/dev/null)"
    #
    #
    error() {
        echo "error: $*" >&2
    }
    #
    declare -A res
    capture res convertpath_split_Readwritemode Readwritemode_out Path_out "$Path"
    #
    assertEquals ":rw"             "${Readwritemode_out}"
    assertEquals "/some/path"      "${Path_out}"
    #
    assertEquals "Wrong suffix should fail with exitCode=1"   1 "${res[exitCode]}"
    assertEquals ""                "${res[stdout]}"
    assertContains "Wrong suffix should emit warning on stderr" "${res[stderr]}" "x11docker WARNING:"
    echo "---here---"
    assertEquals 1 2
}



xxtest_convertpath(){

    #
    # gobal variables used in convertpath
    #
    local Hostuserhome="@(Hostuserhome)"
    local HOME="@(HOME)"
    #
    local Sharefoldercontainer # Sharefoldercontainer : prefixed to stdout
    local Sharefolder          # Possible prefix of Path
    #
    local Winsubmount          # Possible prefix of Path
    #
    local Createcontaineruser  # yes|no
    local Sharehome            # host
    local Containeruserhome
    local Containerpath
    local Containeruserhosthome
    local Persistanthomevolume
    
    # Arguments
    local Mode 
    local Path   # prefix/common_path{:ro|:rw}
    local containerpath_arg

    Hostuserhome="$Hostuserhome" \
    HOME="${HOME}"               \
                
    convertpath "$Mode" "$Path" "$containerpath_arg" 
}

X11DOCKER_TESTING=1
. ../x11docker



. shunit2
