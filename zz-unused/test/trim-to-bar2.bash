#!/bin/bash

#
# Q: can we preserve newlines after the text?
#

trim_to_bar_filter() {
    # shellcheck disable=SC2001
    sed -e 's/^[ \t]*|//'
}

trim_to_bar(){
    echo -n "${1}" | trim_to_bar_filter
}


# Try https://www.gnu.org/software/sed/manual/html_node/Joining-lines.html

x="$(printf "\n\na\n\nb\n\n")"

declare -p x # no newlines after b
#
# Apparently eating the final newlines is NOT sed-specific
#

echo "------------"
printf "\na\nb\n\n"
echo "------------"

#
# ^^ The newlines are there!
#

printf -v x "\na\nb\n"
declare -p x  # The newlines are there!

echo "------------"
echo -n "$x"
echo "------------"
# Still there

y="$(echo -n "$x")"
declare -p y # final newlines lost  

#
# SUFFIX saves final newlines from "$()"
# But then it has to be removed.
#

z="$(echo -n "${x}SUFFIX")"
declare -p z # newlines are saved by a suffix

w="$(trim_to_bar "${x}SUFFIX")"
declare -p z # newlines are saved by a suffix

echo -ne "\n------------\n"
echo -n "${w%SUFFIX}"
echo -ne "\n------------\n"

x="$(trim_to_bar_filter <<< \
                        "|a
                         |b
                         |"
                         )"
printf "%q\n" "$x" # $'a\nb'

x="$(trim_to_bar_filter <<< \
                        "|a
                         |b
                         |
                         |@magic_end_marker@"
                         )"
printf "%q\n" "${x}" # $'a\nb\n\n@'
printf "%q\n" "${x%@magic_end_marker@}" # $'a\nb\n\n'
