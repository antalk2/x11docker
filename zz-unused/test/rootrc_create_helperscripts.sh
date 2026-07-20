#!/bin/bash

myfun() {
    declare_variables

    Sharefoldercontainer="\"\${Sharefoldercontainer}\"/"
    # Sharefolder="/Sharefolder"
    Sharefoldercontainer="/x11docker/"
    g_BackendKind=docker
    Backend="${g_BackendKind}"
    #
    rootrc_create_helperscripts > rootrc_create_helperscripts-out-$suffix.sh
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

meld rootrc_create_helperscripts-out-orig.sh \
     rootrc_create_helperscripts-out-ak.sh

rm rootrc_create_helperscripts-out-orig.sh
rm rootrc_create_helperscripts-out-ak.sh

exit 0

echo "----------------------------"


 

if false ; then

    echo "
# Messagefifofuncs_escaped_1
warning()   {  echo \"\$*:WARNING\"   >>\$Messagefile ; }
note()      {  echo \"\$*:NOTE\"      >>\$Messagefile ; }
verbose()   {  echo \"\$*:VERBOSE\"   >>\$Messagefile ; }
debugnote() {  echo \"\$*:DEBUGNOTE\" >>\$Messagefile ; }
error()     {  echo \"\$*:ERROR\"     >>\$Messagefile ;  exit 64 ; }
stdout()    {  echo \"\$*:STDOUT\"    | sed \"s/\\\$/ /\" >>\$Messagefile ; }"
    echo "Messagefile="${Sharefoldercontainer}"/message.fifo"
    #

fi
