#!/usr/bin/env bash

set_up() {
    X11DOCKER_TESTING=1
    . ./x11docker
}


test_One() {
    assert_same "a" "a" "Demo: success"
    # assert_same "a" "b" "Demo: This is a failure" 
}


#
# test convertpath_split_Readwritemode()
#
test_convertpath_split_Readwritemode_ro() {
    local Readwritemode_out
    local Path_out
    local Path
    #
    # export FDstderr=2 # warning needs it
    #
    Path="/some/path:ro"

    assert_exec "convertpath_split_Readwritemode Readwritemode_out Path_out \"$Path\"" \
                --exit 0    \
                --stdout "" \
                --stderr ""
    #
    assert_same ":ro"         "${Readwritemode_out}"
    assert_same "/some/path"  "${Path_out}"
}

 
test_convertpath_split_Readwritemode_rw() {
     local Readwritemode_out
     local Path_out
     local Path
     #
     export FDstderr=2 # warning needs it
     #
     Path="/some/path:rw"

     assert_exec "convertpath_split_Readwritemode Readwritemode_out Path_out '$Path'" \
                 --exit 0    \
                 --stdout "" \
                 --stderr ""
                 
     #
     assert_same ":rw"         "${Readwritemode_out}"
     assert_same "/some/path"  "${Path_out}"
}

 
test_convertpath_split_Readwritemode_rr() {
    local Readwritemode_out
    local Path_out
    local Path
    #
    #
    export FDstderr=2 # warning needs it
    #
    #
    # Suffix ":.." exists, but is not :ro or :rw
    #
    # Currently (1) Readwritemode_out is set to "rw",
    #           (2) Suffix is NOT removed from Path_out.
    #           (3) A warning() is emitted
    #           (4) return 1 (To allow caller to decide)
    #           
    Path="/some/path:rr"
    Readwritemode_out='UNCHANGED'
    #
    #my_error() {
    #    echo "x11docker ERROR: (from my_error) $*" >&2 ;
    #    # exit 1
    #}
    #
    declare_variables # create global variables with default values
    #
    assert_exec "convertpath_split_Readwritemode Readwritemode_out Path_out '$Path'" \
                --exit 1    \
                --stdout "" \
                --stderr-contains "x11docker WARNING:"
    #
    assert_same ":rw"             "${Readwritemode_out}"
    assert_same "/some/path:rr"   "${Path_out}"
}

test_convertpath() {
    #
    # gobal variables used in convertpath
    #
    local Hostuserhome="@(Hostuserhome)"
    local HOME="@(HOME)"
    #
    local Sharefoldercontainer="@(Sharefoldercontainer)" # prefixed to stdout
    local Sharefolder="@(Sharefolder)"  # Possible prefix of Path
    #
    local Winsubmount="@(Winsubmount)"  # Possible prefix of Path
    #
    local Createcontaineruser  # yes|no
    local Sharehome            # host
    local Containeruserhome
    local Containerpath
    local Containeruserhosthome
    local Persistanthomevolume
    
    # Arguments
    local Mode=share
    local Path=prefix/path:ro   # prefix/common_path{:ro|:rw}
    local containerpath_arg=''

    export FDstderr=2 # warning needs it

    # Hostuserhome="$Hostuserhome"
    # HOME="${HOME}"
    
    assert_exec "convertpath share 'prefix/path:ro' 'containerpath_arg'"--exit 0 --stderr "" \
                --stdout "@(Sharefoldercontainer)prefix/path"
    assert_exec "convertpath share 'prefix/path:rw' 'containerpath_arg'"--exit 0 --stderr "" \
                --stdout "@(Sharefoldercontainer)prefix/path"

    ## Case of a problematic rw-mode suffix
    ## convertpath ignores return value from convertpath_split_Readwritemode
    ##
    assert_exec "(convertpath share 'prefix/path:rr' 'containerpath_arg')" --exit 0 \
                --stderr-contains "x11docker WARNING:" \
                --stdout "@(Sharefoldercontainer)prefix/path:rr"
}
