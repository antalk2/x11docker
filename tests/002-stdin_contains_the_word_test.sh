#!/usr/bin/env bash

set_up() {
 X11DOCKER_TESTING=1
 . ./x11docker
}

#
# Test stdin_contains_the_word
#

test_stdin_contains_the_word_1() {
    #
    # Plain words match
    #
    stdin_contains_the_word "abc" <<< "abc def ghi"
    assert_exit_code 0  "First word"
    #
    stdin_contains_the_word "def" <<< "abc def ghi"
    assert_exit_code 0  "Middle word"
    #
    stdin_contains_the_word "ghi" <<< "abc def ghi"
    assert_exit_code 0  "Last word"
}

test_stdin_contains_the_word_2() {
    #
    # Ugly words match
    #
    stdin_contains_the_word "abc-def!@#$%^" <<< "abc-def!@#$%^ def ghi"
    assert_exit_code 0  "First word"
    #
    stdin_contains_the_word "def-def!@#$%^" <<< "abc def-def!@#$%^ ghi"
    assert_exit_code 0  "Middle word"
    #
    stdin_contains_the_word "ghi-def!@#$%^" <<< "abc def ghi-def!@#$%^"
    assert_exit_code 0  "Last word"
}



test_stdin_contains_the_word_3() {
    #
    #
    #
    # Override here, otherwise set_up will reinstate x11docker's error()
    #
    error_ttm() {
        echo "myerror: $(trim_to_mark "$@" )" >&2
        exit 7
    }
    #
    # Space in pattern is an error.
    #
    f1() {
        ## To catch an exit, use subshell
        (stdin_contains_the_word "abc def" <<< "abc def ghi")
    }
    assert_exec "f1" \
                --exit 7 \
                --stderr-contains "myerror: stdin_contains_the_word():" \
                --stdout ""

    #
    # Tab in pattern is an error.
    #
    f2() {
        ## To catch an exit, use subshell
        (stdin_contains_the_word "$(printf "a\tb" )" <<< "abc def ghi")
    }
    assert_exec "f2" \
                --exit 7 \
                --stderr-contains "myerror: stdin_contains_the_word():" \
                --stdout ""
    #
    # Empty pattern is an error
    #
    f3() {
        ( stdin_contains_the_word "" <<< "abc def ghi" )
    }
    assert_exec "f3" \
                --exit 7 \
                --stderr-contains "myerror: stdin_contains_the_word():" \
                --stdout ""
    
}


test_stdin_contains_the_word_4() {
    local L="0 90 180 270  flipped-90 flipped-180 flipped-270"
    #
    stdin_contains_the_word "flipped" <<< "$L"
    assert_exit_code 1  "We consider hyphen a word character"
    #
    stdin_contains_the_word "flipped-90" <<< "$L"
    assert_exit_code 0  "We consider hyphen a word character"
}
