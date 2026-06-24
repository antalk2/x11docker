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
    export FDstderr=2 # warning needs it
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

test_convertpath_share() {
    #
    # If mode is "share"
    #
    # - split Readwritemode
    # - expand tilde
    # - replace Sharefolder prefix with Sharefoldercontainer
    #   - Spec: if Path is empty, emit ""
    #
    #
    local Sharefoldercontainer="@(Sharefoldercontainer)" # prefixed to stdout
    local Sharefolder="@(Sharefolder)"  # Possible prefix of Path
    #
    
    # Arguments
    #
    # local Mode=share
    # local Path=prefix/path:ro   # prefix/common_path{:ro|:rw}
    local containerpath_arg='' # not used for share

    export FDstderr=2 # warning needs it

    ## remove rw-mode suffix, expand tilde,
    assert_exec "convertpath share '@(Sharefolder)prefix/path:ro' '$containerpath_arg'"--exit 0 --stderr "" \
                --stdout "@(Sharefoldercontainer)prefix/path"
    assert_exec "convertpath share 'prefix/path:rw' '$containerpath_arg'"--exit 0 --stderr "" \
                --stdout "@(Sharefoldercontainer)prefix/path"

    ## Case of a problematic rw-mode suffix
    ## convertpath ignores return value from convertpath_split_Readwritemode
    ##
    assert_exec "(convertpath share 'prefix/path:rr' 'containerpath_arg')" --exit 0 \
                --stderr-contains "x11docker WARNING:" \
                --stdout "@(Sharefoldercontainer)prefix/path:rr"
    #
    # If the path contains a tilde, it is replaced with "${Hostuserhome:-${HOME:-}"
    local Hostuserhome="@(Hostuserhome)"
    local HOME="@(HOME)"
    assert_exec "convertpath share              '@(Sharefolder)~prefix/path:ro' '$containerpath_arg'" \
                --exit 0 --stderr "" \
                --stdout "@(Sharefoldercontainer)@(Hostuserhome)prefix/path"
    ##
    unset Hostuserhome
    assert_exec "convertpath share              '@(Sharefolder)~prefix/path:ro' '$containerpath_arg'" \
                --exit 0 --stderr "" \
                --stdout "@(Sharefoldercontainer)@(HOME)prefix/path"
    ##
}

test_convertpath_2() {
    #
    # If Mode is not share, and Path does not start with "/", then
    #
    # - split Readwritemode
    # - expand tilde
    # - normalize path: Replace // with / and  \ with /   in Path
    # - remove prefix Winsubmount
    # - split Drive from Path
    # - Mode can be volume or mount
    #   - If container, echo "${containerpath_arg:-/$Path}"
    #   - echo "$Path" with a debugnote
    #
    local Hostuserhome="@(Hostuserhome)"
    local HOME="@(HOME)"
    #
    # local Sharefoldercontainer="@(Sharefoldercontainer)" # prefixed to stdout
    # local Sharefolder="@(Sharefolder)"  # Possible prefix of Path
    #
    local Winsubmount="@(Winsubmount)"  # Possible prefix of Path
    #
    #local Createcontaineruser  # yes|no
    #local Sharehome            # host
    #local Containeruserhome
    #local Containerpath
    #local Containeruserhosthome
    #local Persistanthomevolume
    
    # Arguments
    # local Mode=share
    # local Path=prefix/path:ro   # prefix/common_path{:ro|:rw}
    local containerpath_arg=''

    export FDstderr=2 # warning needs it

    ## Mode=volume, no containerpath_arg
    assert_exec "convertpath volume '${Winsubmount}~prefix//lala\\path:ro' '$containerpath_arg'" --exit 0 --stderr "" \
                --stdout "'@(Hostuserhome)prefix/lala/path':'/@(Hostuserhome)prefix/lala/path':ro"

    ## Mode=volume, with containerpath_arg: replaces the second path
    containerpath_arg="@(containerpath_arg)"
    assert_exec "convertpath volume '${Winsubmount}~prefix//lala\\path:rw' '$containerpath_arg'" --exit 0 --stderr "" \
                --stdout "'@(Hostuserhome)prefix/lala/path':'@(containerpath_arg)':rw"
    ##
    ## Mode=volume, with containerpath_arg:
    assert_exec "convertpath mount '${Winsubmount}~prefix//lala\\path:rw' '$containerpath_arg'" --exit 0 --stderr "" \
                --stdout "type=volume,source='@(Hostuserhome)prefix/lala/path',target='@(containerpath_arg)'"
    ## Mode=volume, without containerpath_arg:
    containerpath_arg=''
    assert_exec "convertpath mount '${Winsubmount}~prefix//lala\\path:rw' '$containerpath_arg'" --exit 0 --stderr "" \
                --stdout "type=volume,source='@(Hostuserhome)prefix/lala/path',target='/@(Hostuserhome)prefix/lala/path'"
    ##
}


test_convertpath_3() {
    #
    # If Mode is not share, and Path does start with "/", then
    #
    # - split Readwritemode
    # - expand tilde
    # - normalize path: Replace // with / and  \ with /   in Path
    # - remove prefix Winsubmount
    # - split Drive from Path
    # - Set global: Containerpath
    #   - Initially Containerpath="$Path"
    #     - May replace prefix Containeruserhome with /home.host
    #     - May overwrite with "/home.host/$Containeruser"
    #
    local Hostuserhome="@(Hostuserhome)"
    local HOME="@(HOME)"
    #
    local Winsubmount="/@(Winsubmount)"  # Possible prefix of Path. Here starts with "/"
    #
    # Containerpath depends on:
    #     [ "$Createcontaineruser" = "no" ]
    #     [ "$Sharehome" = "host" ]
    #     $Containeruserhome
    #
    local Createcontaineruser  # yes|no
    local Sharehome            # host
    local Containeruserhome
    local Containerpath
    local Winsubsystem
    
    #local Containeruserhosthome
    #local Persistanthomevolume
    
    # Arguments
    # local Mode=share
    # local Path=prefix/path:ro   # prefix/common_path{:ro|:rw}
    local containerpath_arg=''

    export FDstderr=2 # warning needs it

    ## Mode=unix (or subsystem) : return Path
    Winsubsystem=''
    Createcontaineruser="yes"
    Sharehome="not-host"
    Containeruserhome="@(Containeruserhome)"
    containerpath_arg=''
    assert_exec "convertpath volume '${Winsubmount}/~prefix//lala\\path:ro' '$containerpath_arg'" --exit 0 --stderr "" \
                --stdout "'/@(Hostuserhome)prefix/lala/path':'/@(Hostuserhome)prefix/lala/path':ro"
    assert_same  "/@(Hostuserhome)prefix/lala/path" "${Containerpath}"
    #
    Createcontaineruser="yes"
    Sharehome="not-host"
    Containeruserhome="/@(Hostuserhome)"
    assert_exec "convertpath volume '/~/prefix//lala\\path:ro' '$containerpath_arg'" --exit 0 --stderr "" \
                --stdout "'/@(Hostuserhome)/prefix/lala/path':'/home.host/prefix/lala/path':ro"
    assert_same  "/home.host/prefix/lala/path" "${Containerpath}"
    #
    Createcontaineruser="no"
    Sharehome="not-host"
    Containeruserhome="/@(Hostuserhome)"
    assert_exec "convertpath volume '/~/prefix//lala\\path:ro' '$containerpath_arg'" --exit 0 --stderr "" \
                --stdout "'/@(Hostuserhome)/prefix/lala/path':'/@(Hostuserhome)/prefix/lala/path':ro"
    assert_same  "/@(Hostuserhome)/prefix/lala/path" "${Containerpath}"
    ##
    #
    Createcontaineruser="no"
    Sharehome="not-host"
    Containeruserhome="/@(Hostuserhome)"
    assert_exec "convertpath mount '/~/prefix//lala\\path:ro' '$containerpath_arg'" --exit 0 --stderr "" \
    --stdout "type=bind,source='/@(Hostuserhome)/prefix/lala/path',target='//@(Hostuserhome)/prefix/lala/path',readonly"
    assert_same  "/@(Hostuserhome)/prefix/lala/path" "${Containerpath}"
    #
    Createcontaineruser="yes"
    Sharehome="not-host"
    Containeruserhome="/@(Hostuserhome)"
    assert_exec "convertpath mount '/~/prefix//lala\\path:ro' '$containerpath_arg'" --exit 0 --stderr "" \
     --stdout "type=bind,source='/@(Hostuserhome)/prefix/lala/path',target='//home.host/prefix/lala/path',readonly"
    assert_same  "/home.host/prefix/lala/path" "${Containerpath}"
    ##
}
