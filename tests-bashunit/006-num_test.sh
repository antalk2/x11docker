#!/usr/bin/env bash

fn_exists() { declare -F "$1" > /dev/null; }


# Test the copy in x11docker if it exists
set_up() {
    X11DOCKER_TESTING=1
    . ./x11docker
    ## if ! fn_exists debugnote ; then
        debugnote() {
            echo "DEBUGNOTE: '$*'"  >&2
        }
        error() {
            echo "ERROR: '$*'" >&2
            exit 0
        }
    ## fi
    if true || ! fn_exists isnum ; then
        # ------------------------------------------------------------
        # ------------------------------------------------------------
        :
    fi

    if true || ! fn_exists num_compare ; then
        # ------------------------------------------------------------
        # ------------------------------------------------------------
        :
    fi

    if true || ! fn_exists is_num_in_interval ; then
        # ------------------------------------------------------------
        # ------------------------------------------------------------
        :
    fi
}

unalias_if_aliased() {
    local name="${1:-}"
    if [ -z "${name}" ] ; then
        echo "unalias_if_aliased: name is empty" >&2
        return 1
    fi
    if alias "$1" >/dev/null 2>/dev/null ; then
        unalias "$1"
    fi
}


unalias_if_aliased awk
# alias awk="busybox awk"
# alias awk="awk"
# alias awk="gawk"
# alias awk="mawk"
# alias awk="POSIXLY_CORRECT=1 awk"



test_isnum_001_exponential_yes() {
    isnum -2.1e-3
    assert_exit_code 0
}

test_isnum_002_hex_yes() {
    isnum 0xff
    assert_exit_code 1
}

test_isnum_003_octal_no() {
    isnum 010
    assert_exit_code 1
}

test_isnum_003_ff_no() {
    isnum ff
    assert_exit_code 1
}

test_isnum_003_empty_no() {
    isnum ""
    assert_exit_code 1
}

#
# Some awks can use inf +inf -inf
#
# We do not need that here, so just refuse these
#
test_isnum_004_inf_no() {
    # 
    isnum inf
    assert_exit_code 1
}

test_isnum_004_plus_inf_no() {
    isnum +inf
    assert_exit_code 1
}

test_isnum_004_minus_inf_no() {
    isnum -inf
    assert_exit_code 1
}

#
# num_compare a op b
#

test_num_compare_001_zero_lt_one() {
    bashunit::set_test_title "num_compare: 0 < 1 yes"
    #
    (num_compare 0 "<" 1) # Warning: The quotes are required.
    assert_exit_code 0
}

test_num_compare_002_zero_lt_one() {
    bashunit::set_test_title "num_compare: 0.0 < 1e0 yes"
    #
    (num_compare 0.0 "<" 1e0)
    assert_exit_code 0
}


f1() {
    (num_compare 010 "<" 10)
}

f2() {
    (num_compare 10 "<" 010)
}

test_num_compare_002_octal() {
    #
    # Refuse octal numbers in comparison
    #
    bashunit::set_test_title "num_compare octal A: 010 < 10 is error"
    #
    assert_exec f1 --exit 0 --stdout "" --stderr-contains "ERROR"
    #
}

test_num_compare_003_octal() {
    #
    # Refuse octal numbers in comparison
    #
    bashunit::set_test_title "num_compare octal B: 10 < 010 is error"
    #
    assert_exec f2 --exit 0 --stdout "" --stderr-contains "ERROR"
    #
}

f3() {
    (is_num_in_interval 0.01 "[0,1]")    
}

test_is_num_in_interval_001() {
    bashunit::set_test_title "is_num_in_interval 0.01 '[0,1]' is yes"
    assert_exec f3 --exit 0 --stdout "" --stderr ""
}

test_is_num_in_interval_002() {
    bashunit::set_test_title "is_num_in_interval 1.01 '[0,1]' is no"
    is_num_in_interval 1.01 "[0,1]"
    assert_exit_code 1
}

test_is_num_in_interval_003() {
    bashunit::set_test_title "is_num_in_interval 0 '(0,1]' is no"
    is_num_in_interval 0 "(0,1]"
    assert_exit_code 1
}

test_is_num_in_interval_004() {
    bashunit::set_test_title "is_num_in_interval 0 '[0,1]' is yes"
    is_num_in_interval 0 "[0,1]"
    assert_exit_code 0
}

test_is_num_in_interval_005() {
    bashunit::set_test_title "is_num_in_interval 1 '[0,1]' is yes"
    is_num_in_interval 1 "[0,1]"
    assert_exit_code 0
}

test_is_num_in_interval_006() {
    bashunit::set_test_title "is_num_in_interval 1 '[0,1)' is no"
    is_num_in_interval 1 "[0,1)"
    assert_exit_code 1
}

