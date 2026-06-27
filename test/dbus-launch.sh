#!/bin/bash

echo "Attempt 1, no quotes"

unset BUS_SESSION_BUS_ADDRESS
unset DBUS_SESSION_BUS_PID
unset DBUS_SESSION_BUS_WINDOWID

export $(dbus-launch)

declare -p DBUS_SESSION_BUS_ADDRESS
declare -p DBUS_SESSION_BUS_PID
declare -p DBUS_SESSION_BUS_WINDOWID

echo "Done 1" # good

if true ; then
    echo
    echo "Attempt 2, double-quotes"

    unset DBUS_SESSION_BUS_ADDRESS
    unset DBUS_SESSION_BUS_PID
    unset DBUS_SESSION_BUS_WINDOWID

    export "$(dbus-launch)" # wrong, the first variable gets all the
                            # rest as value

    echo "DBUS_SESSION_BUS_ADDRESS: '${DBUS_SESSION_BUS_ADDRESS:-MISSING}'"
    echo
    echo "DBUS_SESSION_BUS_PID:      '${DBUS_SESSION_BUS_PID:-MISSING}'"
    echo "DBUS_SESSION_BUS_WINDOWID: '${DBUS_SESSION_BUS_WINDOWID:-MISSING}'"
    echo "Done 2" # bad

fi

# Result: do NOT put quotes around $(dbus-launch)

