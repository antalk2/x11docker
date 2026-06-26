#!/bin/bash

#
# Replace each space in $1 with a newline (lf) character
#
spaces_to_newlines() {
    local x="${1}"
    echo "${x// /$'\n'}"
}

echo -e "Expect:\n---\na\nb\nc\n---\n"
spaces_to_newlines "--- a b c ---"

echo -e "Expect:\n---\na\n\nb\nc\n---\n"
spaces_to_newlines "--- a  b c ---"
