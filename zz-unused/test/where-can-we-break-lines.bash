#!/bin/bash


# Q: Where can we break lines?

Hostsystem="ThisSystem"
Host_system_to_report="$(     \
        grep                  \
          '^PRETTY_NAME'      \
           /etc/os-release    \
           2>/dev/null        \
        | cut -d= -f2         \
        || echo "$Hostsystem" \
)"

# This is sufficient.
Host_system_to_report="$(
        grep                  \
          '^PRETTY_NAME'      \
           /etc/os-release    \
           2>/dev/null        \
        | cut -d= -f2         \
        || echo "$Hostsystem"
)"



echo "$Host_system_to_report"



Createcontaineruser=yes
Containeruser='@(Containeruser)'

Container_user_will_be="$(
    [ "$Createcontaineruser" = "yes" ]  \
    && echo "$Containeruser"            \
    || echo "(retaining USER of image)"
)"

Container_user_will_be=JAJ

## All-in-one logical line: needs more semicolons
Container_user_will_be="$(                        \
    if [ "$Createcontaineruser" = "yes" ] ; then  \
       echo "$Containeruser" ;                    \
    else                                          \
       echo "(retaining USER of image)" ;         \
    fi                                            \
)"

# if-then-else is a single command
Container_user_will_be="$(
    if [ "$Createcontaineruser" = "yes" ] ; then
       echo "$Containeruser"
    else
       echo "(retaining USER of image)"
    fi
)"


echo "${Container_user_will_be}"

case "b" in
    a       \
        | b \
        | c )
        echo yes
        ;;
esac

case "b" in
    a  | \
    b  | \
    c  )
        echo yes
        ;;
esac
