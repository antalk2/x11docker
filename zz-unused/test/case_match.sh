#!/bin/bash

# man bash
#
#   case word in [ [(] pattern [ | pattern ] ... ) list ;; ] ... esac
#
#    A case command first
#
#          expands word,
#
#    and tries to match it against each pattern in turn, using
#    the matching rules described under Pattern Matching below.

#    The word is expanded using

#    - tilde expansion,
#    - parameter and variable expansion,
#    - arithmetic expansion,
#    - command substitution,
#    - process substitution
#    - and quote removal.
#
#    Each pattern examined is expanded using
#
#    - tilde expansion,
#    - parameter and variable expansion,
#    - arithmetic expansion,
#    - command substitution,
#    - process substitution,
#    - and quote removal.
#
#    If the nocasematch shell option is enabled, the match is
#    performed without regard to the case of alphabetic characters.
#

# Function: case_match
# Usage: case_match value pattern [{show-cmd|quiet|""}]
# Brief: Does value match a case PATTERN?
# Arguments:
#   value   : string. The value to be matched
#   pattern : string. Used as a case pattern.
#             Example: "--weston*|--xpra*-xwayland"
#   show_cmd : optional, default: quiet
#
# return: 0 is matches
#
# Purpose: Allow to rewrite
#
#        case "$value" in a|b*|c?|[e-f]) cmd ;; esac
#
#     to
#
#        if case_match "$value" "a|b*|c?|[e-f]" ; then cmd ; fi
#
# Note: bash has [[ string =~ REGEXP ]] 
#
case_match() {
    local value="$1"
    local pattern="$2"
    local show_cmd="${3:-}"
    local cmd

    case "$show_cmd" in
        show-cmd) show-cmd="yes" ;;
        ""|quiet) show_cmd="no" ;;
        *)
            echo "case_match: arg3, if provided, should be in {show-cmd|quiet|''} " >&2
            return 2
            ;;
    esac
    
    cmd="$(
         printf "case \"%s\" in %s) true ;; *) false ;; esac" \
                "${value}"                                    \
                "${pattern}"
    )"
    if [  "$show-cmd" = yes ] ; then echo; echo "$cmd" ; echo; fi
    eval "$cmd"
}

#
# Special characters
#

#
# How to tell not to evaluate value and pattern?
#

#
printf "\n** Escape $ with a backslash\n"
#
printf "val='\\\${var}' variable-expanded? Expect no:  "
var="one"
if case_match '\${var}' 'one' ; then echo yes; else echo no; fi

printf "pat='\\\${var}' variable-expanded? Expect no:  "
var="one"
if case_match 'one' '\${var}' ; then echo yes; else echo no; fi


#
# Use printf "%s" to escape? Seems OK
#
var="one"
# pat="$( printf %q  '${var}' )" # \{ and \} are not needed


#
# Try to create a purpose-made function.
# 
printf "\n** case_match_pat case_match_val\n"

case_match_pat() {
    # Escape the pattern
    echo "${1:-}" | LC_ALL=C sed -e 's/[$\\]/\\&/g; '
}

case_match_val() {
    # Escape the value
    echo "${1:-}" | LC_ALL=C sed -e 's/[$\\]/\\&/g; '
}

pat="$( case_match_pat '${var}' )"

printf "pat=%s\n" "$pat"
#
printf "Is escaped pat variable-expanded? Expect no:  "
if case_match 'one' "$pat"  ; then echo yes; else echo no; fi


#
printf "\n*** Escape the dollar. No need to escape the braces.\n"
#

var=one
printf "Is val='\\\${var}' variable-expanded? Expect no: "
if case_match '\${var}' 'one'  ; then echo yes; else echo no; fi

printf "Is pat='\\\${var}' variable-expanded? Expect no: "
if case_match 'one' '\${var}'  ; then echo yes; else echo no; fi

printf "Does  val='\\\${var}' match pat='\\\${var}' Expect yes: "
if case_match '\${var}' '\${var}'  ; then echo yes; else echo no; fi

printf "Does case_match_val '\${var}' mathces case_match_pat '\${var}'  Expect yes: "
if case_match "$(case_match_val '${var}' )"  "$(case_match_pat '${var}' )"   ; then echo yes; else echo no; fi

# echo "reveal=$reveal"


printf "\n** How does 'case' work?\n"

printf "\n*** Tilde expansion\n"

printf "Tilde expansion1: val='~' expanded? Expect no: "
case '~' in "${HOME}") echo yes ;; *) echo no ;; esac

printf "Tilde expansion2: val=~   expanded? Expect yes: "
case ~ in "${HOME}") echo yes ;; *) echo no ;; esac

printf "Tilde expansion3: val=\"~\" expanded? Expect no: "
case "~" in "${HOME}") echo yes ;; *) echo no ;; esac

printf "Tilde expansion4: val=\"\$tilde\" tilde-expanded? Expect no: "
tilde='~'
case "$tilde" in "${HOME}") echo yes ;; *) echo no ;; esac

printf "Tilde expansion4: val=\"\$tilde\" variable-expanded to '~'? Expect yes: "
tilde='~'
case "$tilde" in '~') echo yes ;; *) echo no ;; esac

printf "\n*** process substitution\n"


printf "process substitution of val: Expect yes: "
case "$(cat <( echo huhu ) )" in 'huhu')  echo yes ;; *) echo no ;; esac

printf "process substitution of pat: Expect yes: "
case huhu in  "$(cat <( echo huhu ) )" )  echo yes ;; *) echo no ;; esac

printf "process substitution of pat is after pattern separation: Expect no: "
case huhu in  "$(cat <( echo 'huhu|haha' ) )" )  echo yes ;; *) echo no ;; esac

printf "process substitution of pat is after pattern separation: Expect yes: "
case huhu in  "$(cat <( echo 'huhu' ) )" | haha )  echo yes ;; *) echo yes ;; esac

# exit 0

#
printf "\n** Back to case_match\n"
printf "\n*** Basic matching\n"
#
printf "Expect yes: "
if case_match "--xpra2-xwayland" "--weston*|--xpra*-xwayland" ; then echo yes; else echo no; fi

printf "Expect no:  "
if case_match "--xpra2-wayland" "--weston*|--xpra*-xwayland" ; then echo yes; else echo no; fi

printf "Expect no:  "
if case_match "ton*" "--weston*|--xpra*-xwayland" ; then echo yes; else echo no; fi


#
# Alternatives with '|'
#

printf "Expect no:  "
if case_match "a|b" "a|b" ; then echo yes; else echo no; fi

printf "Expect yes: "
if case_match "a" "a|b" ; then echo yes; else echo no; fi


#
# Question mark
#
printf "Expect yes: "
if case_match "abc" "a?c" ; then echo yes; else echo no; fi

printf "Expect no:  "
if case_match "abbc" "a?c" ; then echo yes; else echo no; fi

printf "Expect no:  "
if case_match "ac" "a?c" ; then echo yes; else echo no; fi

#
# Character range
#

printf "Expect yes: "
if case_match "abc" "a[a-z]c" ; then echo yes; else echo no; fi

printf "Expect no: "
if case_match "abc" "a[c-z]c" ; then echo yes; else echo no; fi

printf "Expect yes: "
if case_match "123" "[0-9][0-9][0-9]" ; then echo yes; else echo no; fi

printf "Expect no: "
if case_match "123" "[0-9][0-9]" ; then echo yes; else echo no; fi
