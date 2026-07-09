#!/bin/bash


# Function: report_cmd
#
# Brief: Eval a_command (potentially twice) and report its exitcode,
#        and a few lines of stdout and stderr)
#
# Purpose: Investigate behavior of utilities.
#
# Usage: report_cmd a_command
#
# Argument: a_command : A string containing a command to check.
#
# stdout: A summary in YAML-like format.
#
# Example:
#
#    report_cmd "ps --version"
#
# prints
#
# ---
# report_cmd:
#   command: ps --version
#   exitcode: 0
#   stdout: "ps from procps-ng 4.0.4"
#   stderr: ""
# ---
#
report_cmd() {
    local command_with_args=""
    #
    local n_head_lines=3
    #
    if [ "$#" -gt 2 ] ; then
        if [ "$1" = "-n" ] ; then
            n_head_lines="$2"
            shift 2
        fi
    fi
    #
    local command_with_args="$1"
    #
    stdout="$( eval $command_with_args       2>/dev/null )"
    stderr="$( eval $command_with_args 2>&1  1>/dev/null )"
    exitcode=$?
    #
    # Report all three.
    printf -- "---\n"
    printf "report_cmd:\n"
    printf "  command: $command_with_args\n"
    printf "  exitcode: $exitcode\n"
    #
    if [ "$(echo "$stdout" | wc -l)" -gt 1 ] ; then
        printf "  stdout: |\n%s\n"        \
               "$(echo "$stdout"          \
                 | sed -e 's|^|    |g'    \
                 | head -n $n_head_lines  )"
    else
        printf "  stdout: \"%s\"\n" "$stdout"
    fi
    #
    if [ "$(echo "$stderr" | wc -l)" -gt 1 ] ; then
        printf "  stderr: |\n%s\n"         \
               "$(echo "$stderr"           \
               | sed -e 's|^|    |'g       \
               | head -n $n_head_lines     )"
    else
        printf "  stderr: \"%s\"\n" "$stderr"
    fi
    #
    printf -- "---\n"
    #
}


# report_cmd "ps --version"
# report_cmd "busybox ps --version"


if false ; then
    # Note: $cmd in itself cannot expand to a pipe.
    # We can have $cmd | head -n 1
    # or we can   eval $cmd
    #
    cmd="awk --version | head -n 1"
    eval $cmd
fi

#report_cmd "awk --version | head -n 1"
#report_cmd -n 3 "busybox awk --version "
#report_cmd -n 10 "awk --help "
#report_cmd -n 10 "busybox awk --help "


# Function: tool_version
# Usage: tool_version [--line|--ERE] "awk_command"
#
# Brief: Try to find out the awk version of "awk_command"
#
# Argument:
#
#   --ERE : report the ERE regular expression selected as matching.
#
#   --line : report the line of output selected as containing the
#            version instead of the extracted value.
#            Sometimes it reveals more details.
#
#  "tool_command" A command we are investigating.
#                Examples: "awk" "gawk" "busybox awk" /usr/bin/awk ps "busybox ps"
#
# stdout: On success, normally the version detected in "A_Word 1.2.3" format.
#
#         Characters not in [A-Za-z0-9_] in "A Word" are replaced with
#         underscore, duplicate, initial and final underscores are
#         removed.
#
#         If --line was selected, show the whole line.
#         If --ERE was selected, show the mathing regular expression.
#
# Description: Attempts to find out the version from
#
#     output="$( eval $mycmd --version  2>&1 )"
#
#     For this, we use a list of ERE regular expressions, grep and sed.
#     The first matching ERE is used to extract the details.
#
#     Note: tool_version() does not attempt to identify the purpose of
#           the command, only which variant is there. For example
#           from 'dd (coreutils) 9.4' we select "coreutils 9.4".
#
#
tool_version() {
    local mycmd
    local output=""
    local ERE
    local name_part=""
    local vernum_part=""
    local line=""
    #
    local show_the_line=""
    local show_the_ERE=""
    local EREs
    #
    EREs='|
          |^(GNU Awk) ([0-9.]+)[^0-9.].*$
          |^(BusyBox) v([0-9.]+) .*$
          |^ps from (procps-ng) ([0-9.]+)$
          |^dd [(](coreutils)[)] ([0-9.]+)$
          |^diff [(](GNU diffutils)[)] ([0-9.]+)$
          |^(bc) ([0-9.]+)$
          |^sed [(](GNU sed)[)] ([0-9.]+)$
          |^This is (not GNU sed) version ([0-9.]+)$
          |^cut [(]GNU (coreutils)[)] ([0-9.]+)$
          |^env [(]GNU (coreutils)[)] ([0-9.]+)$
          |^GNU (bash), version ([0-9.]+).*$
          |'

    #
    if [ "$#" -gt 1 ] ; then
        if [ "$1" = "--line" ] ; then
            show_the_line="yes"
            shift
        elif [ "$1" = "--ERE" ] ; then
            show_the_ERE="yes"
            shift
        else
            echo "tool_version: unexpected argument: '$1'"  >&2
            echo "Usage: tool_version [ --line ] \"cmd\"" >&2
            return 1
        fi
    fi
    #
    mycmd="$1"
    #
    output="$( eval $mycmd --version  2>&1 )"
    #
    #
    while  IFS=''  read -r  ERE ; do
        ERE="$( echo "$ERE" | sed -E -e 's/^[ \t]*[|]//' )"
        if [ -z "${ERE}" ] ; then
            continue
        fi
        if echo "$output" | grep -q -E -e "${ERE}" ; then
            break
        else
            ERE=''
        fi
    done < <( echo "$EREs" )
    #
    if [ -z "$ERE" ] ; then
        echo "tool_version_line: Could not decide (no match)" >&2
        printf "output: |\n---------\n%s\n-------\n" "$output" >&2
        return 1
    fi
    #
    if [ "$show_the_ERE" ] ; then
        printf "The selected ERE is: '%s'\n" "$ERE"
        return 0
    fi
    #
    line="$( echo "$output" | grep  -E -e "${ERE}"  )"
    if [ "$show_the_line" ] ; then
        printf "The line is: '%s'\n" "$line"
        return 0
    fi
    name_part="$( echo "$line" | sed -E -e "s|${ERE}|\1|"    \
                  | LC_ALL=C  tr -cs '[A-Za-z0-9_]' '_'    \
                  | sed -E -e 's|_+$||'
                  )"
    #
    vernum_part="$( echo "$line" | sed -E -e "s|${ERE}|\2|"  )"
    echo "${name_part} ${vernum_part}"
    return 0
}

#
# sh ash dash fail 
#
# if false ; then
for cmd in awk gawk "busybox awk" "/usr/bin/env awk" \
               ps "busybox ps"    \
               dd diff            \
               bc "busybox bc"    \
               sed  "busybox sed" \
               cut  "busybox cut" \
               env "busybox env"  bash  ; do
    printf "%-18s  -> \"%s\"\n" "$cmd"  "$( tool_version  "$cmd"  )"
done
#fi

for f in shopt awk sed cut head tail sh ; do
    echo
    echo "*** $f ***"
    for SH in bash dash ash sh "busybox ash"  "busybox sh" ; do
        printf "%-15s '%s'\n"  "\"$SH\""   "$( $SH -c "command -V $f" )"
    done
done

echo
echo "*** Features ***"
echo "**** Arrays"
for SH in bash dash ash sh "busybox ash"  "busybox sh" ; do
    if $SH -c 'array=( a b c );  [ "x${array[1]}x" = "xbx" ] ' 2>/dev/null ;
    then printf "%-15s : arrays: yes\n" "$SH"
    else printf "%-15s : arrays: no\n"  "$SH"
    fi
done

#
# Distinctions (sh) so far (on my machine)
#
# bash  is the only one having
#       - --version
#       - shopt
#       - Arrays
#
# busybox sh, busybox ash VS others : sh is sh, awk is awk
#
# 
#
