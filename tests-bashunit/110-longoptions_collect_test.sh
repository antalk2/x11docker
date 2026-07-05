#!/usr/bin/env bash

set_up() {
 X11DOCKER_TESTING=1
 . ./x11docker
}


test_longoptions_collect() {
    local L2
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

    local Longoptions=""

    # Influencing auto-setup of X/Wayland/x11docker
    Longoptions="$Longoptions,auto,desktop,tty,wayland,wm::,xc::,xonly,xw"

    # X servers
    Longoptions="$Longoptions,hostdisplay,nxagent,runx,xephyr,xpra,xpra2,xorg,xvfb"

    # X servers depending on a Wayland compositor
    Longoptions="$Longoptions,weston-xwayland,xpra-xwayland,xpra2-xwayland,xwayland,satellite"

    assert_same "$Longoptions" "$L2"

    if false ; then
        if [ "$L2" = "$Longoptions" ] ; then
            echo "result: L2 = Longoptions"
        else
            echo "result: L2 differs from Longoptions"
            echo "L2         | $L2"
            echo "Longoptions| $Longoptions"
        fi
    fi
}

