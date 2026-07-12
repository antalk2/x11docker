#!/usr/bin/env bash


# Test the copy in x11docker
set_up() {
 X11DOCKER_TESTING=1
 . ./x11docker
}

test_join_with() {
    assert_same "a,b,c" "$(join_with ',' a b c )"
    assert_same "a(separator)b(separator)c" "$(join_with '(separator)' a b c )"
}

test_join_with_comma() {
    assert_same "a,b,c" "$(join_with_comma a b c )"
}
