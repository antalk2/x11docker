#!/bin/bash

# shellcheck disable=SC2034
X11DOCKER_TESTING=1
# shellcheck disable=SC1091
. ../x11docker

L1="$(trim_to_bar \
    "|# Influencing auto-setup of X/Wayland/x11docker
     | auto desktop tty wayland wm:: xc:: xonly xw
     |    
     |# X servers
     | hostdisplay nxagent runx xephyr xpra xpra2 xorg xvfb
     |
     |# X servers depending on a Wayland compositor
     | weston-xwayland xpra-xwayland xpra2-xwayland xwayland satellite
     |"   )"

# drop comments
# shellcheck disable=SC2001
L2=$(echo "$L1" | sed -e 's/#.*//')
# list of words, comma-separated. Add initial comma to match original
# shellcheck disable=SC2001
#
# shellcheck disable=SC2086 # (info): Double quote to prevent globbing
#                             and word splitting. We do want word
#                             splitting here. Not globbing, though.
#
L2=",$(echo $L2  | sed -e 's/[ ][ ]*/,/g')"

longoptions_collect() {
    # Starting from a space-separated list of options
    # with optional comments (starting with #),
    # create a comma-separated list.
    #
    # Also include an initial comma, to match the original
    # Longoptions value.
    #
    local L1 L2
    L1="$(trim_to_bar "$1"  )"
    #
    # drop comments
    # shellcheck disable=SC2001
    L2=$(echo "$L1" | sed -e 's/#.*//')
    #
    # List of words, comma-separated.
    # Add initial comma to match original
    # shellcheck disable=SC2001
    #
    # shellcheck disable=SC2086 # (info): Double quote to prevent globbing
    #                             and word splitting. We do want word
    #                             splitting here. Not globbing, though.
    #
    L2=",$(echo $L2  | sed -e 's/[ ][ ]*/,/g')"
    #
    echo "${L2}"
}

L2="$(longoptions_collect \
    "|# Influencing auto-setup of X/Wayland/x11docker
     | auto desktop tty wayland wm:: xc:: xonly xw
     |    
     |# X servers
     | hostdisplay
     | nxagent  # NX agent
     | runx
     | xephyr xpra xpra2 xorg xvfb
     |
     |# X servers depending on a Wayland compositor
     | weston-xwayland xpra-xwayland xpra2-xwayland xwayland satellite
     |"   )"


Longoptions=""

# Influencing auto-setup of X/Wayland/x11docker
Longoptions="$Longoptions,auto,desktop,tty,wayland,wm::,xc::,xonly,xw"

# X servers
Longoptions="$Longoptions,hostdisplay,nxagent,runx,xephyr,xpra,xpra2,xorg,xvfb"

# X servers depending on a Wayland compositor
Longoptions="$Longoptions,weston-xwayland,xpra-xwayland,xpra2-xwayland,xwayland,satellite"


if [ "$L2" = "$Longoptions" ] ; then
    echo "result: L2 = Longoptions"
else
    echo "result: L2 differs from Longoptions"
    echo "L2         | $L2"
    echo "Longoptions| $Longoptions"
fi
