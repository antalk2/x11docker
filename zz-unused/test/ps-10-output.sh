#!/bin/bash

#
# Q: ps  and busybox ps  for -o pid,ppid
#

. ps-01-version.sh

if false; then
    #
    # Versions of ps we know about.
    #
    report_cmd "ps --version"
    report_cmd "busybox ps --version"

    report_cmd "ps --help"
    report_cmd "busybox ps --help"


    show_ps_version_line  "ps"
    show_ps_version_line "busybox ps"
    show_ps_version_line "$( which  ps )"

    echo
fi

# Helper functions to normalize ps output.



normalize2() {
    # Only keeps two columns.
    awk '{ print $1, $2 }'
}

normalize3() {
    # Only needs sed.
    #
    # unispace. trim left and right
    # - For unspecified number of columns.
    #
    sed -E -e 's|[ \t]+| |g ; s|^[ ]*|| ; s|[ ]*$||'
}

normalize_pad4() {
    # pad, unispace. Leaves separator around each line
    sed -E -e 's|^(.*)$| \1 | ;  s|[ \t]+| |g ;'
    # sed -E -e 's|^(.*)$|:\1:| ;  s|[ \t:]+|:|g ;'
}

cmd1="        ps ax -o pid,ppid"
cmd2="busybox ps ax -o pid,ppid"




run_cmds() {
    local mypid
    local tmpfile1a tmpfile2a
    local tmpfile1b tmpfile2b
    local tmpfile1c tmpfile2c
    #
    tmpfile1a="ps-sh-temp1a.tmp"
    tmpfile2a="ps-sh-temp2a.tmp"
    tmpfile1b="ps-sh-temp1b.tmp"
    tmpfile2b="ps-sh-temp2b.tmp"
    tmpfile1c="ps-sh-temp1c.tmp"
    tmpfile2c="ps-sh-temp2c.tmp"
    #
    # To simplify comparison of outputs, run the two cmds without
    # extra processes
    #
    $1 > "$tmpfile1a"
    $2 > "$tmpfile2a"
    #
    # Clean our own PID in either column
    mypid=$$
    #
    cat "$tmpfile1a" | grep -w -v "${mypid}"  > "$tmpfile1b"
    cat "$tmpfile2a" | grep -w -v "${mypid}"  > "$tmpfile2b"
    #
    # Normalize
    cat "$tmpfile1b"  | normalize3 > "$tmpfile1c"
    cat "$tmpfile2b"  | normalize3 > "$tmpfile2c"
    #
    printf "* diff\n----------\n"
    diff --report-identical-file \
          "$tmpfile1c"   \
          "$tmpfile2c"
    exitcode=$?
    printf -- "------------\n* diff exitcode: $exitcode\n"
    #
    if [ "$exitcode" = 0 ] ; then
        printf "\n* head\n"
        head "$tmpfile1c"
    else
        printf "\n* omitting head\n"
    fi
    #
    unlink "$tmpfile1a"
    unlink "$tmpfile2a"
    unlink "$tmpfile1b"
    unlink "$tmpfile2b"
    unlink "$tmpfile1c"
    unlink "$tmpfile2c"
}

run_cmds "$cmd1" "$cmd2"

echo DONE

