#!/bin/bash


#  while ! grep -q "${3:-}" <"${2:-}" ; do

if grep -q "a" <<< "aa" ; then echo yes ; else echo no ; fi

if ! grep -q "a" <<< "aa" ; then echo yes ; else echo no ; fi

# Result ! cmd does work in the condtition position.

true  ; echo $?
false ; echo $?

! true  ; echo $?
! false ; echo $?

# Result ! before a cmd negates it exit value

echo ret

ret(){
    return $1
}

! ret 13 ; echo $?   # 0
! ! ret 21 ; echo $? # 21
! ( ! ret 11 ) ; echo $? # 1




