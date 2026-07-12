#!/bin/bash


# Function: join_with
# Brief: SEP="$1",  join the rest of "${@}" by SEP
#
# Usage: join_with SEP [ s1 ... sn ]
#
# Description: Joins the strings s1 ... sn with separator SEP
#
# Example: join_with ":" "${groupname}" "${gid}" "$Containeruser"
# Example: variable="$(join_with " \\${NEWLINE}" "${variable}"  "--option1" "--option2" )"
# Example: variable+="$(join_with " \\${NEWLINE}" ""  "--option1" "--option2" )"
#
# Argument:
#
#   SEP : may be empty, may contain newline, may contain
#         multicharacter string.
#
#   s1 ... sn : strings to join.
#               n=0 is allowed, yields ""
#               s1="" yields "${SEP}${s2} ... ${SEP}${sn}",
#                            which is empty for n=1.
#
join_with_sh_v1() {
    local SEP="${1}"
    local s1="${2:-}"
    local si
    shift 2
    #
    # Directly to stdout
    printf "%s" "${s1}"
    for si in "${@}" ; do
        printf "%s" "${SEP}${si}"
    done
}


join_with_sh_v2() {
    local SEP="${1}"
    local s1="${2:-}"
    local si
    shift 2
    #
    # Build in res, emit in one
    local res="${s1}"
    for si in "${@}" ; do
        res="${res}${SEP}${si}"
    done
    printf "%s" "${res}"
}

#
# https://stackoverflow.com/questions/1527049/how-can-i-join-elements-of-a-bash-array-into-a-delimited-string
#
join_with_bash() {
    local SEP="${1}"
    local s1="${2:-}"
    shift 2
    printf %s "${s1}" "${@/#/${SEP}}"
}


join_with() {
    join_with_sh_v2 "${@}" ;
}


# Function: join_with_character
# Usage: join_with_character SEP [ s1 ... sn ]
# Brief: Similar to join_with, but SEP must be a single character (or empty)
#
join_with_character() {
    #
    if [ "$( printf %s "$1" | wc -c )" -gt 1 ] ; then
        echo "join_with_character: SEP '${1}' is more than one character" >&2
        return 2
    fi
    #
    local IFS="$1"
    shift
    #
    printf "%s" "${*}"
}


join_with_comma() {
    join_with_character "," "${@}"
}


# Function: join_with_prefix
# Usage: join_with_prefix PREFX s1 ... sn
# Brief: "${PREFX}${s1} ... ${PREFX}${sn}"
#
# Description: Same as join_with PREFX "" s1 ... sn
#
join_with_prefix_sh_v1() {
    local PREFIX="${1}"
    shift
    #
    local res=""
    local si
    for si in "${@}" ; do
        res="${res}${PREFIX}${si}"
    done
    printf "%s" "${res}"
}


NEWLINE=$'\n'

printf "\n%s\n" 'join_with_sh_v1 "," a b c'
join_with_sh_v1 "," a b c
echo


printf "\n%s\n" 'join_with_sh_v2 ";" a b c'
join_with_sh_v2 ";" a b c
echo

printf "\n%s\n" 'join_with_bash ":" a b c'
join_with_bash ":" a b c
echo

printf "\n%s\n" 'join_with "@" a b c'
join_with "@" a b c
echo

printf "\n%s\n" 'join_with_comma a b c'
join_with_comma a b c
echo

printf "\n%s\n" 'join_with_character "xyz" a b c # error'
join_with_character "xyz" a b c # error
echo

echo join_with_character "/" a b c
join_with_character "/" a b c

echo
printf "\n%s\n" 'join_with_character "" a b c'
join_with_character "" a b c


echo
printf "\n%s\n" 'join_with_prefix_sh_v1 ">" a b c'
join_with_prefix_sh_v1 ":>" a b c
