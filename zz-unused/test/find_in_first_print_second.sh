#!/bin/bash



# -------------------------------------
# Function: find_in_first_print_second
# Usage:  cat "$file" | find_in_first_print_second query
#
# stdin: A file with at least two whitespace-separated columns.
#         Whitespace before the first column is ignored.
#
# Argument:
#   query : a string, containing no whitespace
#
# stdout: The value (or values) from column2 of the lines
#         where column1 == query. The output values are separated by newlines.
#
# Used-by: get_ppid, check_parent_sshd
#
find_in_first_print_second() {
    # Extra "" quotes around query, to make it a string for awk.
    local query="\"${1:-}\""
    awk ' $1 == '"${query}"' { print $2 } '
}
# -------------------------------------


printf "a b\n c d\n e f" | find_in_first_print_second e

alias awk=busybox awk
printf "a b\n c d\n e f" | find_in_first_print_second e


