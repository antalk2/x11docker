#!/usr/bin/env bash

set_up() {
 X11DOCKER_TESTING=1
 . ./x11docker
}

#
# Test stdin_contains_any_word
#

test_stdin_contains_any_word_1() {
    #
    # Newline in pattern means multiple patterns
    #
    stdin_contains_any_word "$( printf "a\nb\nc" )" <<< "b"
    assert_exit_code 0  "Newline-separated multiple patterns are OK"
    #
    # stdin_contains_any_word also converts "$1" to newline_separated_words.
    # So we can use it like this:
    #
    stdin_contains_any_word "a b c"  <<< "b"
    assert_exit_code 0  "Space-separated multiple patterns are also OK"
    #
}
