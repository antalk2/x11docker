#!/usr/bin/env bash

set_up() {
 X11DOCKER_TESTING=1
 . ./x11docker
}

#
# https://unix.stackexchange.com/questions/248226/how-to-preserve-the-newline-character-n-when-capture-output-of-a-command-in-a
#
# > It is a known flaw of "command expansion" $(...) or `...` that the
# > last newline is trimmed.
#
# Apperently not only the last, but all the trailing newlines are
# trimmed.
#
test_roundtrip() {
    # Store in variable, echo, store
    local expected x1 x2
    local z="ZZ"
    x1='ab`c$zd!e  f\tg\\h'
    # echo
    x2="$(echo "$x1")"
    assert_same "$x1" "$x2"  "store-echo-store"
    #
    # echo -n
    x2="$(echo -n "$x1")"
    assert_same "$x1" "$x2"  "echo -n"
    #
    # echo -e
    # Expands \a ... \n \t \v \0nnn \xHH ...
    x2="$(echo -e "$x1")"
    local x1_backslash_expanded='ab`c$zd!e  f	g\h'
    assert_same "$x1_backslash_expanded" "$x2" "echo -e"
    #
    # printf "%s"
    x3="$(printf "%s" "$x1")"
    assert_same "$x1" "$x3" 'printf "%s"'
    #
    # printf -v x3 "%s"
    x3=xxx
    printf -v x3 "%s" "$x1"
    assert_same "$x1" "$x3" 'printf -v x3 "%s"'
    #
    # printf "%b"
    x3="$(printf "%b" "$x1")"
    assert_same "$x1_backslash_expanded" "$x3" 'printf "%b"'
    #
    # printf "%q"
    x3="$(printf "%q" "$x1")"
    #
    #                      x1='ab`c$zd!e  f\tg\\h'
    local x1_quoted_for_shell='ab\`c\$zd\!e\ \ f\\tg\\\\h'
    #             esaped: backtick dollar ! space backspace
    #
    assert_same "$x1_quoted_for_shell" "$x3" 'printf "%q"'
    #
    # "$()" loses (any amounty of) trailing newlines, but preserves
    #       initial newlines
    #
    local NEWLINE=$'\n'
    local x4="${NEWLINE}${NEWLINE}a${NEWLINE}${NEWLINE}${NEWLINE}${NEWLINE}"
    local x5="$( echo -n "$x4" )"
    expected="${NEWLINE}${NEWLINE}a"
    assert_same "$expected" "$x5"  '$() loses trailing newlines'
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

test_trim_follows_variable_expansion() {
    #
    # Since trimming happens AFTER variable expansion,
    # the bar before xxx is removed due to $a inserting a newline.
    #
    # Consequence: beware of multiline expansions, and expansions at
    # the beginning of a line. Best if each line starts literal text.
    #
    local a=$'\n'
    local x expected
     x="$(trim_to_bar \
         "|abc$a    |xxx
          | def
          |  ghi")"
     expected="$(printf "abc\nxxx\n def\n  ghi")"
     assert_same "$expected" "$x"
     #
     # With single quotes, no expansion of $a
     #
     x="$(trim_to_bar \
         '|abc$a    |xxx
          | def
          |  ghi')"
     expected="$(printf "abc\$a    |xxx\n def\n  ghi")"
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

test_trim_to_mark_colon_preserves_rest_of_line() {
    ##
    ## A bar after a colon marker is not affected by trim_to_mark.
    ##
    local NEWLINE=$'\n'
    local pattern="$(trim_to_mark \
                  '|:colon_after_bar
                   :|bar_after_colon
                   ::colon_after_colon
                   ||bar_after_bar' )"
    local expected=':colon_after_bar|bar_after_colon:colon_after_colon'
    expected+="${NEWLINE}|bar_after_bar"
    assert_same "$expected" "$pattern" 
}

test_trim_to_mark_3() {
    local NEWLINE=$'\n'
    ## "$(trim_to_mark "$x")" eats only trailing newlines
    local x="$(trim_to_mark "${NEWLINE}a${NEWLINE}a${NEWLINE}")"
    local expected="${NEWLINE}a${NEWLINE}a"
    assert_same "$expected" "$x" '"$(trim_to_mark "$x")"'
    #
    ## "$(trim_to_bar "$x" )"
    local y="$(trim_to_bar "${NEWLINE}${NEWLINE}a${NEWLINE}${NEWLINE}")$(trim_to_bar "a${NEWLINE}")"
    local expected="${NEWLINE}${NEWLINE}aa"
    assert_same "$expected" "$y"
    #
    # How about prefixed lines?
    #
    # "$trim_to_bar "$x")" peserves initial newlines and newlines between text,
    # but not newlines after the text.
    #
    local z="$(trim_to_bar \
         "|
          |a
          |
          |b
          |
          |")"
    local expected="${NEWLINE}a${NEWLINE}${NEWLINE}b"
    assert_same "$expected" "$z"  "trim_to_bar prefixed lines"
    #
    # trim_to_mark also peserves bar-prefixed initial newlines and newlines betwwen text,
    # but not bar-prefixed newlines after the text.
    #
    local w="$(trim_to_mark \
         "|
          |a
          |
          |b
          |
          |")"
    assert_same "$expected" "$z"  "trim_to_mark bar-prefixed lines"

}

