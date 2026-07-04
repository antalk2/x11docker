#!/bin/bash

#
# x11docker uses
#
#     sed -i 's/.*getty/##getty disabled by x11docker## \0/' /etc/inittab
#
# to disable getty in the container.
#

#
# https://www.networkworld.com/article/930604/unix-how-to-the-linux-etc-inittab-file.html
# Unix How To: The Linux /etc/inittab file.
# Basically, # at the start of a line makes the line a comment.
#

#
# Q: Why the \0 at the end of the replacement?
# A: That is not the NUL caharacter, it copies the whole match,
#    so we just prepend '##getty disabled by x11docker## ' to the line.
#

an_example_line='S1:12345:respawn:/sbin/getty -L 115200 ttyS1'

after="$(
      {
          echo aaa
          echo "$an_example_line" ;
          echo xxx
      } | sed -e 's/.*getty/##getty disabled by x11docker## \0/'
 )"

printf "\nafter: (%q)\n" "$after"

echo abc | sed -e 's|b|x|'
