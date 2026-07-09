#!/bin/sh

START="$(pwd)"

cd ../.. \
    && "$START/callGraph" x11docker                           \
                          -language sh                        \
                          -start main                         \
                          -ymlOut "$START/callgraph-out.yaml" \
                          -ignore "exec|note|debugnote|trim_to_mark|trim_to_bar|error|warning|logentry|note_ttm|error_ttm|warning_ttm|waitforlogentry_sh"

#                           -noShow                             \
