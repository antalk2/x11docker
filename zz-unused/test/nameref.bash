#!/bin/bash

f() {
    if [ ${#} -ne 2 ] ; then
        echo "f should have exactly 2 parameters, not  ${#}" 1>&2
        exit 1
    fi
    declare -n out="$1"
    declare -n status="$2"
    out="Hello"
    status=1
    return 1
}

g(){
    # declare out1
    declare -i status1
    f  "out1" "status1"
    return "$status1"
}

die() {
    echo "die: $1"
}

declare -i status1

g || die "jaj"

declare  out1

echo "global out: $out"
echo "global status: $status"
echo "global out1: $out1"
echo "global status1: $status1"



if true ; then
    h() { echo 1 ; }
    echo -en "\n-- direct --";  time for ((i=0;i<10000;i++)); do echo 1; done >/dev/null ;
    echo -en "\n-- h --"     ;  time for ((i=0;i<10000;i++)); do h; done >/dev/null 
    # SLOW: echo -en "\n-- (h) --"; time for ((i=0;i<10000;i++)); do (h); done >/dev/null 
    echo -en "\n-- (for h) --"; time (for ((i=0;i<10000;i++)); do h; done) >/dev/null 
    echo -en "\n-- (for h) --"; time (for ((i=0;i<10000;i++)); do h; done >/dev/null )
fi


# slow: 4.569s/10k
# echo -en '\n--x=$(echo $i) --'; time for ((i=0;i<10000;i++)); do x=$(echo $i); done >/dev/null

setter(){
    declare -n out="$1"
    local i="$2"
    out="$i"
}

# 0.099s/10k
#
# shellcheck disable=SC2034 # (warning): x appears unused. Verify use (or export if used externally).
declare -i x
# shellcheck disable=SC2016 # (info): Expressions don't expand in single quotes, use double quotes for that.
echo -en '\n-- setter x $i --'; time for ((i=0;i<10000;i++)); do setter x $i; done >/dev/null

ifelse() {
    declare -n result="$1"
    if $2 ; then
        echo "yes"
        result="$3"
    else
        echo "no"
        # shellcheck disable=SC2034 # (warning): result appears
        #                             unused. Verify use (or export if
        #                             used externally).
        result="$4"
    fi
}

echo "-- ifelse --"

declare -g x2

ifelse x2 true "a" "b"
echo "$x2"


echo "--- Path ---"

test1() {
    local Path="$1"
    # shellcheck disable=SC2001 # (style): See if you can use ${variable//search/replace} instead.
    Path1="$(sed "s%~%${Hostuserhome:-${HOME:-}}%" <<< "$Path")"
    Path2="${Path/[~]/${Hostuserhome:-${HOME:-}}}"
    Path3="${Path/#[~]/${Hostuserhome:-${HOME:-}}}"

    echo "orig : $Path"
    echo "sed  : $Path1"
    echo "[~]  : $Path2"
    echo "#[~] : $Path3"
}



HOME="HOME"
Hostuserhome="Hostuserhome"

test1 "/~/aha"

# replace

Path="/a//b//c\\e"
echo ooo "$Path"
echo sed "$(sed 's%//%/%g ; s%\\%/%g' <<< "$Path")"

p1="${Path//\/\//\/}" # // to /
p2="${p1//\\/\/}"     # \ to /
echo pat "$p2"

# abcde="/ab\\cde"
# echo xxx ${abcde/\\/|}
# echo xxx ${abcde/\/\//|}
