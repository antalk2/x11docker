#!/usr/bin/env bash

set_up() {
 X11DOCKER_TESTING=1
 . ./x11docker
}

#
# Test stdin_contains_as_word
#

test_stdin_contains_as_word_1() {
    #
    # Plain words match
    #
    stdin_contains_as_word "abc" <<< "abc def ghi"
    assert_exit_code 0  "First word"
    #
    stdin_contains_as_word "def" <<< "abc def ghi"
    assert_exit_code 0  "Middle word"
    #
    stdin_contains_as_word "ghi" <<< "abc def ghi"
    assert_exit_code 0  "Last word"
}

test_stdin_contains_as_word_2() {
    #
    # Ugly words match
    #
    stdin_contains_as_word "abc-def!@#$%^" <<< "abc-def!@#$%^ def ghi"
    assert_exit_code 0  "First word"
    #
    stdin_contains_as_word "def-def!@#$%^" <<< "abc def-def!@#$%^ ghi"
    assert_exit_code 0  "Middle word"
    #
    stdin_contains_as_word "ghi-def!@#$%^" <<< "abc def ghi-def!@#$%^"
    assert_exit_code 0  "Last word"
}



test_stdin_contains_as_word_3() {
    #
    #
    #
    # Override here, otherwise set_up will reinstate x11docker's error()
    #
    error() {
        echo "myerror: $*" >&2
        exit 7
    }
    #
    # Space in pattern is an error.
    #
    f1() {
        ## To catch an exit, use subshell
        (stdin_contains_as_word "abc def" <<< "abc def ghi")
    }
    assert_exec "f1" \
                --exit 7 \
                --stderr-contains "myerror: stdin_contains_as_word(): Space or Tab found in pattern" \
                --stdout ""

    #
    # Tab in pattern is an error.
    #
    f2() {
        ## To catch an exit, use subshell
        (stdin_contains_as_word "$(printf "a\tb" )" <<< "abc def ghi")
    }
    assert_exec "f1" \
                --exit 7 \
                --stderr-contains "myerror: stdin_contains_as_word(): Space or Tab found in pattern" \
                --stdout ""
    #
    # Empty pattern does not match.
    #
    stdin_contains_as_word "" <<< "abc def ghi"
    assert_exit_code 1  "empty1"
    #
    stdin_contains_as_word "" <<< "$( printf "abc\n\nghi" )"
    assert_exit_code 1  "empty2 We removed duplicate newlines "
    #
    stdin_contains_as_word "" <<< "$( printf "\nabc" )"
    assert_exit_code 1  "empty3 We removed empty lines"
    #
    # Newline in pattern means multiple patterns
    #
    stdin_contains_as_word "$( printf "a\nb\nc" )" <<< "b"
    assert_exit_code 0  "Newline-separated multiple patterns are OK"
}


test_stdin_contains_as_word_4() {
    local L="0 90 180 270  flipped-90 flipped-180 flipped-270"
    #
    stdin_contains_as_word "flipped" <<< "$L"
    assert_exit_code 1  "We consider hyphen a word character"
    #
    stdin_contains_as_word "flipped-90" <<< "$L"
    assert_exit_code 0  "We consider hyphen a word character"
}
