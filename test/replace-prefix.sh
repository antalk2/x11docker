#!/bin/bash

f() {
    local old="/bibi/baba/bubu"
    local prefix="/bibi/baba"
    local replacement="/home.host"

    # shellcheck disable=SC2001 # (style): See if you can use ${variable//search/replace} instead.
    echo  "v1:  $( sed "s%^$prefix%/home.host%" <<< "$old" )"
    echo  "v2:  ${old/#"$prefix"/\/home.host}";
    echo  "v3:  ${old/#"$prefix"/"$replacement"}"
    echo  "v4:  ${old/#$prefix/$replacement}"
}

f


replace_prefix() {
    local old="${1}"
    local prefix="${2}"
    local replacement="${3}"
    echo "${old/#"$prefix"/"$replacement"}"
}

echo ""
