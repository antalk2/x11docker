#!/bin/bash


# Q: what goes where in
#
#
#       Xcnetworkid="$(
#                 unpriv_backend "$Backendbin network create $Internal $Xcnetworkname"
#        )" 2>>$Xinitlogfile || return 1
#

so="$(
      echo "out1"      # stdout goes into so
      echo "out2" >&2  # stderr goes to screen
      exit 13          # exitcode goes to $?
      )"
ec=$?

echo "so=$so"
echo "ec=$ec"
