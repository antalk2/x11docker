#!/bin/bash

#
# Purpose: reduce the verbosity of
#

# shellcheck disable=SC2050 # (warning): This expression is
#                             constant. Did you forget the $ on a
#                             variable?
if [ "one" = "two" ] ; then
    variable="yes"
else
    variable="no"
fi

#
# Variant 1a: uses 'eval $*`. Arg has to be quoted.
#

echo "*** yes_or_no1a ***"

yes_or_no1a() {
    # shellcheck disable=SC2048 # (warning): Use "$@" (with quotes) to prevent whitespace problems.
    # shellcheck disable=SC2086 # (info): Double quote to prevent globbing and word splitting.
    if eval $* ; then
        echo yes
    else
        echo no
    fi
}


x=$(yes_or_no1a  '[ "one" = "two" ]'  )
echo "result: '$x' expect no"

x=$(yes_or_no1a '[ "one" = "one" ]' )
echo "result: '$x' expect yes"

dir_perm_flags="01234w"
# shellcheck disable=SC2016 # (info): Expressions don't expand in single quotes
x=$(yes_or_no1a '[ "${dir_perm_flags:5:1}" == "w" ]'  )
echo "result: '$x' expect: yes"

dir_perm_flags="01234-"
# shellcheck disable=SC2016 # (info): Expressions don't expand in single quotes
x=$(yes_or_no1a '[ "${dir_perm_flags:5:1}" == "w" ]'  )
echo "result: '$x' expect: no"


#
# Variant 1b: uses "${@}"
#

echo
echo "*** yes_or_no1b ***"

yes_or_no1b() {
    if "${@}" ; then
        echo yes
    else
        echo no
    fi
}


x=$(yes_or_no1b  [ "one" = "two" ]  )
echo "result: '$x' expect no"

x=$(yes_or_no1b [ "one" = "one" ] )
echo "result: '$x' expect yes"

dir_perm_flags="01234w"
x=$(yes_or_no1b [ "${dir_perm_flags:5:1}" == "w" ]  )
echo "dp result: '$x' expect: yes"

dir_perm_flags="01234-"
x=$(yes_or_no1b [ "${dir_perm_flags:5:1}" == "w" ]  )
echo "dp result: '$x' expect: no"

if true ; then
    ## $* uses IFS!
    #
    dir_perm_flags="01234w"
    x=$(IFS= yes_or_no1b [ "${dir_perm_flags:5:1}" == "w" ]  )
    echo "IFS result: '$x' expect: yes"
    #
    dir_perm_flags="01234w"
    x=$(IFS= yes_or_no1b [ "${dir_perm_flags:5:1}" == "@" ]  )
    echo "IFS result: '$x' expect: no"
    #
fi


#
# Variant 3: uses '[ "$?" = "0" ]`. To be called after the test.
#

echo "*** yes_or_no2 ***"

yes_or_no2() {
    if [ "$?" = "0" ] ; then
        echo yes
    else
        echo no
    fi
}


x=$( [ "${dir_perm_flags:5:1}" == "w" ] ; yes_or_no2 )
echo "result: '$x' expect: no"

#
# Variant 3: uses a variable, needs eval at call site.
#
# Pro: the variable can be local.
#

echo "*** yes_or_no2 ***"


yes_or_no3=' if [ "$?" = "0" ] ; then echo yes ; else echo no; fi '

# shellcheck disable=SC2086 # (info): Double quote to prevent globbing and word splitting.
x=$( [ "${dir_perm_flags:5:1}" == "w" ] ; eval $yes_or_no3 )
echo "result: '$x' expect: no"

dir_perm_flags="01234w"

# shellcheck disable=SC2086 # (info): Double quote to prevent globbing and word splitting.
x=$( [ "${dir_perm_flags:5:1}" == "w" ] ; eval $yes_or_no3 )
echo "result: '$x' expect: yes"


#
# Decision use variant1b?
#

yes_or_no() {
    if "${@}" ; then
        echo yes
    else
        echo no
    fi
}

# shellcheck disable=SC2319 # (warning): This $? refers to a condition,
#     not a command. Assign to a variable to avoid it being
#     overwritten.
exitcode_yes_or_no() { if [ "$?" = "0" ] ; then echo yes ;  else echo no; fi }

#
# The original
#
if [ "one" = "two" ] ; then
    variable="yes"
else
    variable="no"
fi

#
# becomes
#

variable=$(yes_or_no [ "one" = "two" ] )
echo "res '$variable' expect: no"

variable=$(yes_or_no [ "one" = "one" ] )
echo "res '$variable' expect: yes"

dir_perm_flags='drwxrwxrwx'

if [ "${dir_perm_flags:2:1}" == "w" ] ; then
    dir_is_user_writable=yes
else
    dir_is_user_writable=no
fi
echo "dir_is_user_writable1 ${dir_is_user_writable}"

dir_is_user_writable=$( yes_or_no [ "${dir_perm_flags:2:1}" == "w" ] )
echo "dir_is_user_writable2 ${dir_is_user_writable}"

[ "${dir_perm_flags:2:1}" == "w" ] ;
dir_is_user_writable=$( exitcode_yes_or_no )
echo "dir_is_user_writable3 ${dir_is_user_writable}"


dir_is_user_writable=$( [ "${dir_perm_flags:2:1}" == "w" ] ; exitcode_yes_or_no )
echo "dir_is_user_writable4 ${dir_is_user_writable}"

