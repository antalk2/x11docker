#!/bin/bash

NEWLINE=$'\n'
create_xcommand_HELPER_append_ops_to() {
    declare -n VAR_IO="$1"
    shift
    #
    local op
    local SEP=" \\${NEWLINE}  "
    for op in "${@}" ; do
        VAR_IO+="${SEP}${op}"
    done
}

f() {
    local append_ops_to="create_xcommand_HELPER_append_ops_to"
    $append_ops_to Xserveroptions '-shmem' '-shpix'
    #
    # Can also add multiline op-collection.
    $append_ops_to Xserveroptions $'a \\\n  b \\\n  c'
}

Xserveroptions=''

f

printf "%s" "$Xserveroptions"
