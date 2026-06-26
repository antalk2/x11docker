#!/usr/bin/env bash

set_up() {
 X11DOCKER_TESTING=1
 . ./x11docker
}

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
