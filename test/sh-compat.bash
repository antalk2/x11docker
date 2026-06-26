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

set -x
{
    echo Storeinfofile="sh-compat-generated-store.info"
    declare -f storeinfo_dump_sh
    declare -f storeinfo_drop_sh
    declare -f storeinfo_test_sh
    declare -f storeinfo_add_kv_sh
} > "$generated_file"

shellcheck --shell=sh --norc "$generated_file"
