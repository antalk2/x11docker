#!/usr/bin/env bash

set_up() {
 X11DOCKER_TESTING=1
 . ./x11docker
}

test_roundtrip() {
    # Store in variable, echo, store
    local expected x1 x2
    local z="ZZ"
    x1='ab`c$zd!e  f\tg\\h'
    # echo
    x2="$(echo "$x1")"
    assert_same "$x1" "$x2"
    #
    # echo -n
    x2="$(echo -n "$x1")"
    assert_same "$x1" "$x2"
    #
    # echo -e
    # Expands \a ... \n \t \v \0nnn \xHH ...
    x2="$(echo -e "$x1")"
    local x1_backslash_expanded='ab`c$zd!e  f	g\h'
    assert_same "$x1_backslash_expanded" "$x2" "echo -e"
    #
    # printf "%s"
    x3="$(printf "%s" "$x1")"
    assert_same "$x1" "$x3"
    #
    # printf -v x3 "%s"
    x3=xxx
    printf -v x3 "%s" "$x1"
    assert_same "$x1" "$x3"
    #
    # printf "%b"
    x3="$(printf "%b" "$x1")"
    assert_same "$x1_backslash_expanded" "$x3"
    #
    # printf "%q"
    x3="$(printf "%q" "$x1")"
    #
    #                      x1='ab`c$zd!e  f\tg\\h'
    local x1_quoted_for_shell='ab\`c\$zd\!e\ \ f\\tg\\\\h'
    #             esaped: backtick dollar ! space backspace
    #
    assert_same "$x1_quoted_for_shell" "$x3" "printf %q"
}

test_trim_to_bar_usage() {
     local x expected
     x="$(trim_to_bar \
         "|abc
          | def
          |  ghi")"
     expected="$(printf "abc\n def\n  ghi")"
     assert_same "$expected" "$x"
}

test_trim_to_bar_special_chars() {
    #
    # In "", backslash and dquote needs escape with backslash.
    #
    local x expected
    local z=ZZ
    local sq="'"
    local dd='$z'
     x="$(trim_to_bar \
         "|abc  |\\|\"|$z|
          | def |'|single_quote
          |  ghi|$dd")"
     expected=\
'abc  |\|"|ZZ|
 def |'${sq}'|single_quote
  ghi|$z'
     assert_same "$expected" "$x"
}

 
test_trim_to_mark_usage() {
    local x expected
    x="$(trim_to_mark \
        "|abc
         :d
         :e
         :f
         |ghi")"
    expected="$(printf "abcdef\nghi")"
    assert_same "$expected" "$x" 
}

