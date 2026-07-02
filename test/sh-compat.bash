#!/bin/bash

#
# Problem: While x11docker itself is in bash, the scripts generated
#          for the container tend to declare #! /bin/sh
#
#          So the stuff going into these should be POSX compliant.
#
#

# shellcheck disable=SC2034
X11DOCKER_TESTING=1
# shellcheck disable=SC1091
. ../x11docker


generated_file="sh-compat-generated.sh"

# set -x
{
    # storeinfo
    echo 'Storeinfofile="sh-compat-generated-store.info"'
    declare -f storeinfo_dump_sh
    declare -f storeinfo_drop_sh
    declare -f storeinfo_test_sh
    declare -f storeinfo_add_kv_sh

    #
    # create_xinitrc()
    # ----------------
    #
    # cookiebaker
    declare -f cookiebaker
    declare -f strlenhex

    echo 'Myps="ps"'
    declare -f pspid
    declare -f disable_xhost

    declare -f makecookie_v1
    declare -f makecookie_v2
    echo '# shellcheck disable=SC3028 # (error): In dash, RANDOM is not supported.'
    declare -f makecookie_v3
    declare -f makecookie

    echo Timetosaygoodbyefile="Timetosaygoodbyefile.txt"
    echo Timetosaygoodbyefifo="Timetosaygoodbye.fifo"
    declare -f rocknroll
    declare -f saygoodbye

    #
    # create_containerrc()
    #   -> waitforlogentry_sh()
    #
    declare -f trim_to_bar_filter
    declare -f trim_to_bar
    declare -f trim_to_mark
    declare -f ws_colon_is_continuation_filter
    declare -f waitforlogentry_sh

    declare -f calculate_floor_a_per_b

} > "$generated_file"

for s in bash dash ash sh ; do
    # Ignore SC3043 (warning): In POSIX sh, 'local' is undefined.
    printf "\n%s\n" "shellcheck --shell=\"$s\" --exclude=SC3043 --norc \"$generated_file\""
    shellcheck --shell=$s --exclude=SC3043 --norc "$generated_file"
done


