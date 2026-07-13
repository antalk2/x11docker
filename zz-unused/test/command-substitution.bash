#!/bin/bash

Readwritemode=":ro"
# Readwritemode=":rw"

# Set Readwritemode_mount based on Readwritemode
# local Readwritemode_mount1
if [ "$Readwritemode" = ":ro" ] ; then
    Readwritemode_mount1=",readonly"
else
    Readwritemode_mount1=""
fi


echo "v1 '${Readwritemode_mount1}'"


case "$Readwritemode" in
    ":ro") Readwritemode_mount2=",readonly" ;;
    ":rw") Readwritemode_mount2="" ;;
    *) echo "error: Unexpected Readwritemode '${Readwritemode}'" ;;
esac

echo "v2 '${Readwritemode_mount2}'"


Readwritemode_mount3=$(
    case "$Readwritemode" in
        ":ro") echo -n ",readonly" ;;
    esac;
)

echo "v3 '${Readwritemode_mount3}'"


check_version() {
    local verbose=false
    case "$1" in
        "-v") verbose=true ; shift ;;
    esac
    
    local actual="$1"
    local required="$2"
    
    
    if [ "$(echo -e "$required\n$actual" | sort -V | head -n1)" = "$required" ]; then
        if $verbose ; then echo "Actual version $actual is acceptable." ; fi
        return 0
    else
        if $verbose ; then echo "Actual version $actual is too old. Please upgrade to $required or higher." ; fi
        return 1
    fi    
}

actual=$(echo "${BASH_VERSION}" | cut -d. -f1-2)
required="5.3"
if check_version "${actual}"  "${required}"  ; then
     # shellcheck disable=SC2016
    echo ' ${ local X=12345 ; echo $X; } # Should work'
else
    echo "BASH_VERSION $BASH_VERSION does not support"
    # shellcheck disable=SC2016
    echo " command substitution using braces: "'${ local X=12345 ; echo $X; }'
    echo "    This needs at least version $required"
fi

# 
# 
# #
# # Using a function
# #
# rw_mode_to_mount_mode() {
#     local Readwritemode="$1"
#     case "${Readwritemode}" in
#         ":ro") echo -n ",readonly" ;;
#         ":rw") echo -n "" ;;
#         *)
#             echo "warning: unexpected value in rw_mode_to_mount_mode($1)" >&2 ;
#             return 1
#          ;;
#     esac
#     return 0
# }
# 
# Readwritemode_mount4="$( rw_mode_to_mount_mode  "$Readwritemode" )"
# 
# echo "v4 '${Readwritemode_mount4}'"
# 
# strict() {
#     local res
#     local x
#     (
#         set -e
#         "${@}"
#         res=$?
#         if [ "$res" != "0" ] ; then
#             {
#                 echo "error: strict( ${1} ) caught exit code $res"
#                 for x in "${@}" ; do
#                     echo "    arg: '$x'"
#                 done
#                 echo "  Exiting"
#             } >&2
#             exit $res
#         fi
#     )
# }
# 
# die(){
#     echo "die: $*"  >&2
#     exit 1
# }
# 
# warn(){
#     echo "warn: $*"  >&2
# }
# 
# 
# 
# echo "Expect warning"
# Readwritemode_mount4b="$( rw_mode_to_mount_mode  "xx$Readwritemode" )"
# echo "v4b '${Readwritemode_mount4b}'"
# 
# echo "Expect ',readonly'"
# Readwritemode_mount4c="$( strict rw_mode_to_mount_mode  ":ro" )"
# echo "v4c '${Readwritemode_mount4c}'"
# 
# echo "Expect ''"
# Readwritemode_mount4d="$( strict rw_mode_to_mount_mode  ":rw" )"
# echo "v4d '${Readwritemode_mount4d}'"
# 
# echo "Expect error"
# Readwritemode_mount4d="$( strict rw_mode_to_mount_mode  ":xxx" )"
# echo "v4d '${Readwritemode_mount4d}'"
# 
# echo -e "\n4d Expect die"
# Readwritemode_mount4d="$( rw_mode_to_mount_mode ":xxx" )"  || warn "jaj"
# echo "v4d '${Readwritemode_mount4d}'"
# 
# set -e
# 
# echo -e "\n4e Expect Failed"
# if Readwritemode_mount4e="$( rw_mode_to_mount_mode ":xxx" )" ; then
#     echo "OK"
# else
#     echo "Failed"
# fi
# 
# echo -e "\n4f Expect OK"
# if Readwritemode_mount4f="$( x=5; rw_mode_to_mount_mode ":ro" )" ; then
#     echo "OK, '$Readwritemode_mount4f'"
# else
#     echo "Failed"
# fi
# 


