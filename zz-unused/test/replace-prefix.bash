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


replace_prefix_re_v1() {
    # sed-based, prefix is considered a regexp. Depend: sed
    local old="${1}"
    local prefix="${2}"
    local replacement="${3}"
    #
    # shellcheck disable=SC2001 # -s=bash : See if you can use ${variable//search/replace} instead.
    sed "s%^${prefix}%${replacement}%" <<< "$old"
}


replace_prefix_v2() {
    # bash parameter expansion replacement. Depend: bash
    local old="${1}"
    local prefix="${2}"
    local replacement="${3}"
    #
    # Note: `prefix` could be considered a pattern, but the quotes
    #       around it below disable that
    #
    echo "${old/#"$prefix"/"$replacement"}"
}

replace_prefix_v3() {
    # bash parameter expansion, using ${#prefix} and "${x:offset:length}"
    local old="${1}"
    local prefix="${2}"
    local replacement="${3}"
    #
    local prefix_length="${#prefix}"
    if [ "${old:0:$prefix_length}" = "$prefix" ] ; then
        echo "${replacement}${old:$prefix_length}"
    else
        echo "${old}"
    fi
}

replace_prefix_v4() {
    # Try to avoid bash features. Depend: wc, cut
    local old="${1}"
    local prefix="${2}"
    local replacement="${3}"
    #
    local prefix_length
    local prefix_of_old
    local suffix_of_old
    #
    # shellcheck disable=SC2155 # -s=bash : (warning): Declare and assign separately to avoid masking return values.
    prefix_length="$( printf "%s" "$prefix" | wc --chars )"
    #
    prefix_of_old="$( printf "%s" "$old"    | cut -c 1-"$prefix_length" )"
    if [ "$prefix_of_old" = "$prefix" ] ; then
        # echo "match" >&2
        #
        # suffix starts at (prefix_length+1)
        suffix_of_old="$( printf "%s" "$old"    | cut -c "$prefix_length"- | cut -c 2- )"
        echo "${replacement}${suffix_of_old}"
    else
        # echo "nomatch prefix_length=$prefix_length prefix_of_old=$prefix_of_old" >&2
        echo "${old}"
    fi
}


printf "\nv1\n"
echo "expect ABCdefghi $(replace_prefix_v1 "abcdefghi" "abc" "ABC" )"
echo "expect abcdefghi $(replace_prefix_v1 "abcdefghi" "a*e" "ABC" )"
echo "expect abcdefghi $(replace_prefix_v1 "abcdefghi" "a.*e" "ABC" )" # mismatch in v1

printf "\nv2\n"
echo "expect ABCdefghi $(replace_prefix_v2 "abcdefghi" "abc" "ABC" )"
echo "expect abcdefghi $(replace_prefix_v2 "abcdefghi" "a*e" "ABC" )"
echo "expect abcdefghi $(replace_prefix_v2 "abcdefghi" "a.*e" "ABC" )"

printf "\nv3\n"
echo "expect ABCdefghi $(replace_prefix_v3 "abcdefghi" "abc" "ABC" )"
echo "expect abcdefghi $(replace_prefix_v3 "abcdefghi" "a*e" "ABC" )"
echo "expect abcdefghi $(replace_prefix_v3 "abcdefghi" "a.*e" "ABC" )"

printf "\nv4\n"
echo "expect ABCdefghi $(replace_prefix_v4 "abcdefghi" "abc" "ABC" )"
echo "expect abcdefghi $(replace_prefix_v4 "abcdefghi" "a*e" "ABC" )"
echo "expect abcdefghi $(replace_prefix_v4 "abcdefghi" "a.*e" "ABC" )"
