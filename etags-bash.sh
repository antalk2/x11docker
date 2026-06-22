#!/bin/bash

set -x

etags --language=none \
      --regex=@etags-bash.tags \
       "${@}"

