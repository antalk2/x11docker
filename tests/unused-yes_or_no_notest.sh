#!/usr/bin/env bash

#
# 
#
# Note: Passing code as unquoted arguments does not handle redirections.
#
#       For example:
#
# f(){  printf "'%s' "  "$@" ; echo ; } # Reports its arguments
# f [ a = b ]                           # '[' 'a' '=' 'b' ']' # as expected
# f command -v ls 2>/dev/null           # 'command' '-v' 'ls' # Redirection is not an argument.
# 

set_up() {
 X11DOCKER_TESTING=1
 # . ./x11docker
}

#
# echo yes or echo no depending on exitcode of "${@}"
#
yes_or_no() { if "${@}" ; then echo yes ; else echo no ; fi }


#
# Test yes_or_no()
#
test_yes_or_no() {
    local x
    #
    x=$( yes_or_no [ "1" = "2" ] )
    assert_same "no" "$x"   '[ "1" = "2" ]'
    #
    x=$( yes_or_no [ "1" = "1" ] )
    assert_same "yes" "$x" '[ "1" = "1" ]'
    #
    # Evaluation in yes_or_no should not unexpectedly depend on IFS,
    # but preferably keep expected effects.
    #
    # local IFS # not needed here, runs in subshell
    x=$(IFS= yes_or_no [ "1" = "2" ] )
    assert_same "no" "$x"   'IFS= [ "1" = "2" ]'
    #
    x=$(IFS= yes_or_no [ "1" = "1" ] )
    assert_same "yes" "$x"   'IFS= [ "1" = "1" ]'
    #
    #
    x=$(IFS=';' yes_or_no [ "1" = "1" ] )
    assert_same "yes" "$x"   'IFS=";" [ "1" = "1" ]'
    #
    #
}
