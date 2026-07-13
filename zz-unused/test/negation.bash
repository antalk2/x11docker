#!/bin/bash

#
# Q: How does ! cmd   and   ! pipeline  work in bash?
# Q: How does it work under different shells? (See negation-runner.sh)
#

assert_same() {
    local exp="$1"
    local act="$2"
    local label="${3:-}"
    if [ "$exp" = "$act" ] ; then
        echo "PASS $label"
    else
        echo "FAIL $label, exp='$exp' act='$act'"
    fi
}

#  while ! grep -q "${3:-}" <"${2:-}" ; do

res="$(if echo "aa" | grep -q "a" ; then echo yes ; else echo no ; fi )"
expect=yes
assert_same  "$expect" "$res"  "baseline"

res="$( if !  echo "aa" | grep -q "a" ; then echo yes ; else echo no ; fi )"
expect=no
assert_same  "$expect" "$res"  "! baseline"


# Result ! cmd does work in the condtition position.

res="$( true  ; echo $? )"
expect=0
assert_same  "$expect" "$res"  "true is 0"


res="$( false ; echo $? )"
expect=1
assert_same  "$expect" "$res"  "false is 1"


res="$( ! true  ; echo $? )"
expect=1
assert_same  "$expect" "$res"  "! true is 1"

res="$( ! false ; echo $? )"
expect=0
assert_same  "$expect" "$res"  "! false is 0"


# Result ! before a cmd negates it exit value

# echo ret

ret(){
    return "$1"
}

res="$( !     ret 13   ; echo $? )" # 0
expect=0
assert_same  "$expect" "$res"  "! ret 13 is 0"

if false ; then
    :
    # # "Syntax error: "!" unexpected" in dash, ash, busybox sh for "! ! cmd"
    # res="$( ! !   ret 21   ; echo $? )" # 21
    # expect=21
    # assert_same  "$expect" "$res"  "! ! ret 21 is 21"
fi

res="$( ! ( ! ret 11 ) ; echo $? )" # 1
expect=1
assert_same  "$expect" "$res"  " ! ( ! ret 11 ) is 1"


# Result: `! ! cmd` keeps exitCode of cmd

# echo "Testing: ! a | b"

res="$( ! true  | false ; echo $? )"  # 0
expect=0
assert_same  "$expect" "$res"  "! true  | false is 0"


res="$( ! true  | true  ; echo $? )" # 1
expect=1
assert_same  "$expect" "$res"  "! true  | true is 1"

res="$( ! false | false ; echo $?  )" # 0
expect=0
assert_same  "$expect" "$res"  "! false | false is 0"

res="$( ! false | true  ; echo $? )" # 1
expect=1
assert_same  "$expect" "$res"  "! false | true is 1"

# Result: ! negates exitCode of b
