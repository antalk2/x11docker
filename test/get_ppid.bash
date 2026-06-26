#!/bin/bash

Myps="ps"

get_ppid() {
    local pid_to_check="${1:-empty_pid}"
    local res=''
    res="$( $Myps ax -o pid,ppid                  \
           | grep -E '^\s+'"${pid_to_check}"'\s+' \
           | awk ' { print $2 } '
         )"
    if [ -z "$res" ] ; then
        echo "" # what should be printed here?
        return 1
    else
        echo "$res"
        return 0
    fi
}


echo -n "ppid 1:" ; get_ppid 1 # 9048673

echo -n "ppid 2:" ; get_ppid 2 # 7291613

echo -n "ppid 3:" ; get_ppid 3 #

echo -n 'ppid $$:' ; get_ppid $$

echo -n "ppid x:" ;
res=$(get_ppid nosuchpid)
echo "${res:-(get_ppid failed)}"


