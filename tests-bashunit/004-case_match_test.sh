#!/usr/bin/env bash

if true ; then
    # Test the copy in x11docker
set_up() {
 X11DOCKER_TESTING=1
 . ./x11docker
}
else
    # Test local copy
    
# ---------------------------------------------------------------------
# Function: case_match
# Usage: case_match value pattern
# Brief: Does value match a case PATTERN?
# Arguments:
#   value   : string. The value to be matched
#   pattern : string. Used as a case pattern.
#             Example: "--weston*|--xpra*-xwayland"
#
# return: 0 is matches
#
# Purpose: Allow to rewrite
#
#        case "$value" in a|b*|c?|[e-f]) cmd ;; esac
#
#     to
#
#        if case_match "$value" "a|b*|c?|[e-f]" ; then cmd ; fi
#
# Note: bash has [[ string =~ REGEXP ]] 
#
case_match() {
    local value="$1"
    local pattern="$2"
    local cmd

    cmd="$(
         printf "case \"%s\" in %s) true ;; *) false ;; esac" \
                "${value}"                                    \
                "${pattern}"
    )"
    # echo "$cmd"
    eval "$cmd"
}
# ---------------------------------------------------------------------
fi

#test_case_match_special_characters() {
#    
#    case_match '${xvar}' '${var}'
#    assert_exit_code 0
#    
#}


test_case_match_basic() {
    #
    # Basic matching
    #
    case_match "--xpra2-xwayland" "--weston*|--xpra*-xwayland"
    assert_exit_code 0

    case_match "--xpra2-wayland" "--weston*|--xpra*-xwayland"
    assert_exit_code 1

    case_match "ton*" "--weston*|--xpra*-xwayland"
    assert_exit_code 1
}

test_case_match_altbar() {
    #
    # Alternatives with '|'
    #
    case_match "a|b" "a|b"
    assert_exit_code 1

    case_match "a" "a|b"
    assert_exit_code 0
}

test_case_match_question_mark() {
    #
    # Question mark: matches any single character
    #
    case_match "abc" "a?c"
    assert_exit_code 0

    # Does not match multiple characters
    case_match "abbc" "a?c"
    assert_exit_code 1

    # Does not match zer characters
    case_match "ac" "a?c"
    assert_exit_code 1
}

test_case_match_charater_range() {
    #
    # Character range
    #

    case_match "abc" "a[a-z]c"
    assert_exit_code 0
    
    case_match "abc" "a[c-z]c"
    assert_exit_code 1

    case_match "123" "[0-9][0-9][0-9]"
    assert_exit_code 0

    # Wrong number of digits
    case_match "123" "[0-9][0-9]"
    assert_exit_code 1
}

test_case_match_bad_pattern() {
    f() {  case_match "" 'a b' ; }
    assert_exec "f" --exit 2 --stderr-contains "syntax error" --stdout ""
}

test_case_match_empty_pattern() {

    # Empty a ""
    case_match "" '"" | a | b'
    assert_exit_code 0
    
    # Empty as ''
    case_match "" "'' | a | b"
    assert_exit_code 0
    
    # spaces around alternatives do not match empty
    case_match "" " a | b"
    assert_exit_code 1
}

test_case_match_space_in_pattern() {

    #
    case_match "Hello world" '"Hello world" | "Hello again"'
    assert_exit_code 0
    #
    case_match "Hello again" "'Hello world' | 'Hello again' "
    assert_exit_code 0
   
}

