#!/bin/bash

f(){
    printf "f.x %s " "$x"
}

# Before negation
x=13 f ; echo "exitcode $?" 

# Good

!   x=14 f     ; echo "exitcode $?"
! { x=16 f ; } ; echo "exitcode $?"

# Bad
# x=15 ! f ## Error:  !: command not found
# x=17 { ! f ; } ## Error
