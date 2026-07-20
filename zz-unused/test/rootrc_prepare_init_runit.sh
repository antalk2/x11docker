#!/bin/bash

myfun() {
    declare_variables

    Sharefoldercontainer="\"\${Sharefoldercontainer}\"/"
    # Sharefolder="/Sharefolder"
    Sharefoldercontainer="/x11docker/"
    g_BackendKind=docker
    Backend="${g_BackendKind}"
    #
    rootrc_prepare_init_runit > rootrc_prepare_init_runit-out-$suffix.sh
}


(
# shellcheck disable=SC2034
X11DOCKER_TESTING=1
# shellcheck disable=SC1091
. ../../x11docker
suffix="ak"
myfun
)

(
    x11docker_path=/home/antalk/d/kiosk/zz-unused/x11docker/mviereck-x11docker/x11docker
    sed -e 's|^main |# \0|g' -e 's|^saygoodbye main|# \0|g' < $x11docker_path > tmp.sh
    diff $x11docker_path tmp.sh
    . tmp.sh
    suffix="orig"
    myfun
    rm tmp.sh
)

meld rootrc_prepare_init_runit-out-orig.sh \
     rootrc_prepare_init_runit-out-ak.sh

rm rootrc_prepare_init_runit-out-orig.sh
rm rootrc_prepare_init_runit-out-ak.sh

exit 0

echo "#! /bin/sh
mysleep () 
{ 
    sleep "${1:-1}" 2> /dev/null || sleep 1
}
waitforservice() {
  Service=\$1
  [ \"\$(sv check \$Service | cut -d: -f1)\" = 'ok' ] && {
    echo "x11docker: waiting for service \$Service ..."
    for Count in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20; do
      [ \"\$(sv status \$Service | cut -d: -f1)\" = 'down' ] && mysleep 0.2 || break
    done
  }
}
# make stderr visible
exec 2>&1
# wait for all other services
echo 'Content of /etc/runit/runsvdir/default:'
ls -la /etc/runit/runsvdir/default/*
for Service in /etc/runit/runsvdir/default/* ; do waitforservice \$Service ;done
echo 'Current status of runit services:'
for Service in /etc/runit/runsvdir/default/* ; do sv status      \$Service ;done
/usr/local/bin/x11docker-agetty
"
