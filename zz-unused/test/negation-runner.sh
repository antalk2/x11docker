#!/bin/bash

for s in bash dash ash "busybox sh" ; do
    echo "==================="
    echo "$s negation.bash"
    echo "==================="
    $s negation.bash
done
