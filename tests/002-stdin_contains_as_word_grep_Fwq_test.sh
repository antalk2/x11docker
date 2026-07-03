#!/usr/bin/env bash

#
# This file tests an earlier version of stdin_contains_as_word(),
# which is not anymore used. Only kept as a reminder.
#

set_up() {
 X11DOCKER_TESTING=1
 . ./x11docker
}

#
# function stdin_contains_as_word_grep_Fwq( word ) <<< "$list_of_words"
#
# return 0 if word is found in stdin, non-0 otherwise
#
stdin_contains_as_word_grep_Fwq() {
    # grep: -w, --word-regexp : Select only those lines
    #           containing matches that form whole words.
    #       -F Pattern is interpreted as a fixed string
    #
    #   Word-constituent characters are letters, digits, and the
    #   underscore.
    #
    #  Note: only the boundaries of the match are tested, the match
    #        may contain non-word characters in the match.
    #
    #        Summary: No word-constitent character just before and
    #                 just after the match.
    #
    #  Example: "flipped"    matches "flipped-90"
    #           "flipped-90" matches "flipped-90"
    #
    LC_ALL=C grep -F -q -w -- "${1}"
}


test_stdin_contains_as_word_grep_Fwq_1() {
    #
    stdin_contains_as_word_grep_Fwq "abc" <<< "abc def ghi"
    assert_exit_code 0  "First word"
    #
    stdin_contains_as_word_grep_Fwq "def" <<< "abc def ghi"
    assert_exit_code 0  "Middle word"
    #
    stdin_contains_as_word_grep_Fwq "ghi" <<< "abc def ghi"
    assert_exit_code 0  "Last word"
}

test_stdin_contains_as_word_grep_Fwq_2() {
    #
    # man grep: Word-constituent characters are letters, digits, and
    #           the underscore.
    #
    #     The test is that the matching substring must either be at
    #     the beginning of the line, or preceded by a non-word
    #     constituent character.  Similarly, it must be either at the
    #     end of the line or followed by a non-word constituent
    #     character.
    #
    #     The only thing checked is: no non-word character allowed
    #     just before and just after the match. Anything is allowed
    #     inside that matches the pattern. --> Use the pattern to avoid
    #     non-word characters inside.
    #
    stdin_contains_as_word_grep_Fwq "Az_12" <<< "Az_12"
    assert_exit_code 0  "Underscore and digits"
    #
    # The pattern is actually understood as a pattern_list, where the
    # patterns are separated by a newline. (https://pubs.opengroup.org/onlinepubs/9799919799/utilities/grep.html)
    #
    local qqq="$(printf 'a\nb\nc')"
    #
    stdin_contains_as_word_grep_Fwq "$qqq" <<<  "a"
    assert_exit_code 0  "The pattern is actually understood as a pattern_list"
    #
    stdin_contains_as_word_grep_Fwq "$qqq" <<<  "b"
    assert_exit_code 0  "The pattern is actually understood as a pattern_list"
    #
    stdin_contains_as_word_grep_Fwq "$qqq" <<<  "c"
    assert_exit_code 0  "The pattern is actually understood as a pattern_list"
    #
    stdin_contains_as_word_grep_Fwq "$qqq" <<<  ""
    assert_exit_code 1  "The pattern is actually understood as a pattern_list"
    #
    stdin_contains_as_word_grep_Fwq "$(printf 'a\n\nb')" <<<  ""
    assert_exit_code 0 "Empty line means empty pattern!"
    #
    local L="0 90 180 270  flipped-90 flipped-180 flipped-270"
    #
    stdin_contains_as_word_grep_Fwq "90" <<<  "$L"
    assert_exit_code 0
    #
    stdin_contains_as_word_grep_Fwq "flipped" <<<  "$L"
    assert_exit_code 0 "Hyphen is non-word character, flipped matches to flipped-90"
    #
    stdin_contains_as_word_grep_Fwq "flipped-" <<<  "$L"
    assert_exit_code 1 "digits are word chrs"
    #
    stdin_contains_as_word_grep_Fwq "flipped-90" <<<  "$L"
    assert_exit_code 0 "flipped-90"
    #
}

test_stdin_contains_as_word_grep_Fwq_Dot_inside() {
    #
    # A dot is accepted in the middle, as first, as last, before and
    # after.
    #
    stdin_contains_as_word_grep_Fwq "AA.ZZ" <<< "AA.ZZ"
    assert_exit_code 0 "Dot OK in the midle"
    #
    stdin_contains_as_word_grep_Fwq ".abc" <<< ".abc"
    assert_exit_code 0 "Dot OK as first"
    #
    stdin_contains_as_word_grep_Fwq "abc." <<< "abc."
    assert_exit_code 0 "Dot OK as last"
    #
    stdin_contains_as_word_grep_Fwq "abc" <<< ".abc"
    assert_exit_code 0 "Dot OK before"
    #
    stdin_contains_as_word_grep_Fwq "abc" <<< "abc."
    assert_exit_code 0 "Dot OK after"
    #
}


test_stdin_contains_as_word_grep_Fwq_Underscore_around() {
    #
    stdin_contains_as_word_grep_Fwq "abc" <<< "_abc"
    assert_exit_code 1 "Underscore is not OK before"
    #
    stdin_contains_as_word_grep_Fwq "abc" <<< "abc_"
    assert_exit_code 1 "Underscore is not OK after"
    #
}

