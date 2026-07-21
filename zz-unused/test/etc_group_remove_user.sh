#!/bin/bash


# Function: etc_group_remove_user
# Brief: remove all mentions of a username from an input formatted as /etc/group
#
# Usage: etc_group_remove_user [-i] username input_file
#
# Arguments:
#   -i        : inplace edit the input_file
#  username   : username to remove
#  input_file : Path to the input file. Defaults to "=" meaning stdin.
#               Expected to be formatted as /etc/group
#
etc_group_remove_user() {
    local i_flag=""
    if [ "${1}" = "-i" ] ; then
        i_flag="-i"
        shift
    fi
    #
    local user="${1}"
    local input_file="${2:--}"
    # Format: groupName:password:GID:user1,user2,user3
    # # Handle sole_user, first, middle last
    #
    sed  $i_flag " s/:${user}\$/:/g ;
                   s/:${user},/:/g ;
                   s/,${user},/,/g ;
                   s/,${user}\$//g ;
                 " "${input_file}"
}

# Function: etc_gshadow_remove_user
# Brief: remove all mentions of a username from an input formatted as /etc/gshadow
#
# Usage: etc_gshadow_remove_user [-i] username input_file
#
# Arguments:
#   -i        : inplace edit the input_file
#  username   : username to remove
#  input_file : Path to the input file. Defaults to "=" meaning stdin.
#               Expected to be formatted as /etc/gshadow
#
etc_gshadow_remove_user() {
    local i_flag=""
    if [ "${1}" = "-i" ] ; then
        i_flag="-i"
        shift
    fi
    #
    local user="${1}"
    local input_file="${2:--}"
    # Format: groupName:password:admin1,admin2,admin3:user1,user2,user3
    #
    # Handle sole_user, first_{user|admin}, middle_{user|admin},
    #        last_user, sole_admin, last_admin
    #
    sed  $i_flag " s/:${user}\$/:/g ;
                   s/:${user},/:/g ;
                   s/,${user},/,/g ;
                   s/,${user}\$//g ;
                   s/:${user}:/::/g ;
                   s/,${user}:/:/g ;
                 " "${input_file}"
}

etc_group_remove_user_orig() {
    local user="${1}"
    local input_file="${2:--}"
    # Format: groupName:password:GID:user1,user2,user3
    sed "s/${user}//g ; s/:,/:/g ; s/,\$//g"  "${input_file}"
}

etc_gshadow_remove_user_orig() {
    local user="${1}"
    local input_file="${2:--}"
    # Format: groupName:password:admin1,admin2,admin3:user1,user2,user3
    sed "s/${user}//g ; s/:,/:/g ; s/,\$//g"  "${input_file}"
}


  
red() {
    printf "%b%s%b" '\033[31m' "$1" '\033[0m'
}

green() {
    printf "%b%s%b" '\033[32m' "$1" '\033[0m'
}



# Function: test_one
# Usage: test_one [verbose={true|false}] function_to_test input expected
test_one() {
    local verbose="$1"
    local function_to_test="$2"
    local input="${3}"
    local expected="${4}"
    local res
    res="$( echo "${input}" | "${function_to_test}" joe )"
    local detail=""
    if $verbose ; then
        detail="$(printf " expected: '%s' got: '%s'" "$expected" "$res"  )"
    fi
    if [ "$res" = "$expected" ]
    then echo "$(green PASS)"
    else echo "$(red FAIL)${detail}"
    fi
}

test_user_in_group_field() {
    local verbose=false;  if [ "$1" = "-v" ] ; then verbose=true; shift ;  fi
    local function_to_test="${1}"
    test_one $verbose "${function_to_test}" "joe:x:1:"  "joe:x:1:"
}

test_sole_user() {
    local verbose=false;  if [ "$1" = "-v" ] ; then verbose=true; shift ;  fi
    local function_to_test="${1}"
    test_one $verbose "${function_to_test}" "group:x:1:joe"  "group:x:1:"
}

test_first_user() {
    local verbose=false;  if [ "$1" = "-v" ] ; then verbose=true; shift ;  fi
    local function_to_test="${1}"
    test_one $verbose "${function_to_test}" "group:x:1:joe,bill"  "group:x:1:bill"
}

test_middle_user() {
    local verbose=false;  if [ "$1" = "-v" ] ; then verbose=true; shift ;  fi
    local function_to_test="${1}"
    test_one $verbose "${function_to_test}" "group:x:1:james,joe,bill"  "group:x:1:james,bill"
}

test_last_user() {
    local verbose=false;  if [ "$1" = "-v" ] ; then verbose=true; shift ;  fi
    local function_to_test="${1}"
    test_one $verbose "${function_to_test}" "group:x:1:james,joe"  "group:x:1:james"
}

test_partial_user() {
    local verbose=false;  if [ "$1" = "-v" ] ; then verbose=true; shift ;  fi
    local function_to_test="${1}"
    test_one $verbose "${function_to_test}" "group:x:1:hijoey,joe"  "group:x:1:hijoey"
}


test_etc_group_remove_user() {
    echo "=== etc_group_remove_user =============="
    tests="test_user_in_group_field \
       test_sole_user           \
       test_first_user          \
       test_middle_user         \
       test_partial_user        \
       "

    printf "%-30s %s %s\n"  "test" new orig
    for testfun in $tests ; do
        printf "%-30s"  "$testfun"
        for f in etc_group_remove_user etc_group_remove_user_orig  ; do
            res="$( $testfun -v $f )"
            printf " %s" "${res}"
        done
        printf "\n"
    done
    echo "========================================"
}

gstest_user_in_group_field() {
    # Format: groupName:password:admin1,admin2,admin3:user1,user2,user3
    local verbose=false;  if [ "$1" = "-v" ] ; then verbose=true; shift ;  fi
    local function_to_test="${1}"
    test_one $verbose "${function_to_test}"     \
             "joe:x:admin1:user1"  \
             "joe:x:admin1:user1"
}

gstest_sole_user() {
    local verbose=false;  if [ "$1" = "-v" ] ; then verbose=true; shift ;  fi
    local function_to_test="${1}"
    test_one $verbose "${function_to_test}" \
             "group:x::joe"    \
             "group:x::"
}

gstest_first_user() {
    local verbose=false;  if [ "$1" = "-v" ] ; then verbose=true; shift ;  fi
    local function_to_test="${1}"
    test_one $verbose "${function_to_test}"       \
             "group:x::joe,user1"    \
             "group:x::user1"
}

gstest_middle_user() {
    local verbose=false;  if [ "$1" = "-v" ] ; then verbose=true; shift ;  fi
    local function_to_test="${1}"
    test_one $verbose "${function_to_test}"             \
             "group:x::user1,joe,user2"    \
             "group:x::user1,user2"
}

gstest_last_user() {
    local verbose=false;  if [ "$1" = "-v" ] ; then verbose=true; shift ;  fi
    local function_to_test="${1}"
    test_one $verbose "${function_to_test}" \
             "group:x::user1,joe"    \
             "group:x::user1"
}

gstest_partial_user() {
    local verbose=false;  if [ "$1" = "-v" ] ; then verbose=true; shift ;  fi
    local function_to_test="${1}"
    test_one $verbose "${function_to_test}"                \
             "group:x::user1,hijoey"    \
             "group:x::user1,hijoey"
}

gstest_sole_admin() {
    local verbose=false;  if [ "$1" = "-v" ] ; then verbose=true; shift ;  fi
    local function_to_test="${1}"
    test_one $verbose "${function_to_test}" \
             "group:x:joe:"    \
             "group:x::"
}

gstest_first_admin() {
    local verbose=false;  if [ "$1" = "-v" ] ; then verbose=true; shift ;  fi
    local function_to_test="${1}"
    test_one $verbose "${function_to_test}"       \
             "group:x:joe,admin1:"    \
             "group:x:admin1:"
}

gstest_middle_admin() {
    local verbose=false;  if [ "$1" = "-v" ] ; then verbose=true; shift ;  fi
    local function_to_test="${1}"
    test_one $verbose "${function_to_test}"             \
             "group:x:admin1,joe,admin2:"    \
             "group:x:admin1,admin2:"
}

gstest_last_admin() {
    local verbose=false;  if [ "$1" = "-v" ] ; then verbose=true; shift ;  fi
    local function_to_test="${1}"
    test_one $verbose "${function_to_test}" \
             "group:x::admin1,joe"    \
             "group:x::admin1"
}

gstest_partial_admin() {
    local verbose=false;  if [ "$1" = "-v" ] ; then verbose=true; shift ;  fi
    local function_to_test="${1}"
    test_one $verbose "${function_to_test}"                \
             "group:x::admin1,hijoey"    \
             "group:x::admin1,hijoey"
}



test_etc_gshadow_remove_user() {
    echo "=== etc_gshadow_remove_user =============="
    tests="\
       gstest_user_in_group_field \
       gstest_sole_user           \
       gstest_first_user          \
       gstest_middle_user         \
       gstest_partial_user        \
       gstest_sole_admin           \
       gstest_first_admin          \
       gstest_middle_admin         \
       gstest_partial_admin        \
       "

    printf "%-30s %s %s\n"  "test" new orig
    for testfun in $tests ; do
        printf "%-30s"  "$testfun"
        for f in etc_gshadow_remove_user etc_gshadow_remove_user_orig  ; do
            res="$( $testfun -v $f )"
            printf " %s" "${res}"
        done
        printf "\n"
    done
    echo "========================================"
}


test_etc_group_remove_user

test_etc_gshadow_remove_user
