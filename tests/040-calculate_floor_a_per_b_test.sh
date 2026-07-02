#!/usr/bin/env bash

set_up() {
    X11DOCKER_TESTING=1
    . ./x11docker
    #    declare_variables
}


test_calculate_floor_a_per_b() {
    local x expected
    #
    expected="333"
    x="$(calculate_floor_a_per_b 1000 3)"
    assert_same "$expected" "$x"  "floor( 1000/3 )"
    #
    expected="666"
    x="$(calculate_floor_a_per_b 1000 1.5)"
    assert_same "$expected" "$x"   "floor( 1000/1.5 )"
    #
}
