#!/usr/bin/env bash

set_up() {
 X11DOCKER_TESTING=1
 . ./x11docker
}


# https://github.com/mviereck/x11docker/blob/8357d9425b603942735a8a036f35488609953e48/x11docker#L1531
orig_writeaccess() {                 # check if useruid $1 has write access to folder $2
  local dirVals= gMember= IFS=
  IFS=$'\t' read -a dirVals < <(stat -Lc "%U	%G	%A" "${2:-}")
  [ "$(id -u "$dirVals")" == "${1:-}" ] && [ "${dirVals[2]:2:1}" == "w" ]   && return 0
  [ "${dirVals[2]:8:1}" == "w" ]                                          && return 0
  [ "${dirVals[2]:5:1}" == "w" ] && {
    gMember="$(groups "${1:-}" 2>/dev/null)"
    [[ "${gMember[*]:2}" =~ ^(.* |)${dirVals[1]}( .*|)$ ]]                && return 0
  }
  [ "w" = "$(getfacl -pn "${2:-}" | grep "user:${1:-}:" | rev | cut -c2)" ] && return 0 || return 1
}


# https://github.com/mviereck/x11docker/issues/569

#
# man 2 access
#
#       This allows set-user-ID programs and capability-endowed
#       programs to easily determine the invoking user's authority.
#       In other words, access() does not answer the "can I
#       read/write/execute this file?" question.  It answers a
#       slightly different question: "(assuming I'm a setuid binary)
#       can the user who invoked me read/write/execute this file?",
#       which gives set-user-ID programs the possibility to prevent
#       malicious users from causing them to read files which users
#       shouldn't be able to read.
#
# man 3 eaccess, euidaccess
#
#       whereas access(2) performs checks using the real user and
#       group identifiers of the process, euidaccess() uses the
#       effective identifiers.
#
#



#test_writeaccess() {  writeaccess }
