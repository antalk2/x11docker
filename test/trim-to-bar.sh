#!/bin/bash

#
#  Purpose: Allow lines of multi-line strings to be indented in the
#           source without affecting the value.
#
trim_to_bar_filter() {
    sed -e 's/^[\t ]*|//'
}

trim_to_bar1() {
    # shellcheck disable=SC2001
    echo "${1}" | trim_to_bar_filter
}

if false; then
    x="$(trim_to_bar1 \
        "|aa'a
         |bb
         |")"
    echo "$x"
fi

#trim_to_bar2() {
#    ##
#    ## WRONG. Eats repeated bars!
#    ##
#    shopt -s extglob
#    # local flat="MAGIC${1//$'\n'/MAGIC}"
#    # echo "flat: '$flat'"
#    # echo "${flat//MAGIC*( ))|/}"
#    #
#    # local NEWLINE=$'\n'
#    local flat="${1//*( )|/}"
#    echo "${flat}"
#}


echo "Works1"
trim_to_bar1 "|a
              | b
              |  c"

echo "Repeated bars are not affected1"
trim_to_bar1 "||a  |
              || b |
              ||  c|"


echo "TAB in prefix"
trim_to_bar1 \
	"|a
	 | b
	 |  c"

echo "Special chars in text"
trim_to_bar1 \
	"|a   |? *       |
	 | b  |[](){}    |
	 |  c |\n\t\f\\&'\"|
         |    |      ^  ^| backslash and dquote escaped"

#
# Can we break long lines into this?
#
#  Idea: use a different marker for continuations
#
#  "|a
#   | bbbb
#   :cccc
#   |d"
#

showSpaces(){ tr " " _; }

#
#  Purpose: Allow lines of multi-line strings to be indented in the
#           source without affecting the value.
#
trim_to_mark1() {
    #echo "-- input --"
    #echo "$1"
    # echo "${1}" | sed -e 's/^[\t ]*\([:|]\)/\1/'  -e '//{N;s/\n:/:/}'
    #
    # Without Look ahead: tac reverses order of lines, rev reverses characters in each line
    #
    if false ; then
        echo "Pass1:"
        echo ---
        echo "${1}" | tac | rev | showSpaces
        echo ---
        echo "Pass2:"
        echo ---
        echo "${1}" | tac | rev | sed -e 's/\([:|]\)[\t ]*$/\1/' | showSpaces
        echo ---
        echo "Pass3:"
        echo ---
        echo "${1}" | tac | rev | sed -e 's/\([:|]\)[\t ]*$/\1/' | sed -e '/:$/{N;s/:\n//}' | showSpaces
        echo ---
        echo "Pass4:"
        echo ---
        echo "${1}" | tac | rev | sed -e 's/\([:|]\)[\t ]*$/\1/' | sed -e '/:$/{N;s/:\n//}'  | tac  | rev | showSpaces
        echo ---
        ## Note: Does not work if we join the two sed calls.
    fi
    echo "--- final ----"
    echo "${1}" \
        | tac | rev  \
        | sed -e 's/\([:|]\)[\t ]*$/\1/' \
        | sed -e '/:$/{N;s/:\n//}'  \
        | tac  | rev  \
        | trim_to_bar_filter
}

trim_to_mark2() {
    echo "${1}" \
        | tac | rev  \
        | sed -e '/:[ \t]*$/{N;s/:[ \t]*\n//}'  \
        | sed -e '/:[ \t]*$/{N;s/:[ \t]*\n//}'  \
        | tac  | rev  \
        | trim_to_bar_filter
}

trim_to_mark3() {
    # Based on https://www.gnu.org/software/sed/manual/html_node/Joining-lines.html
    # example: Join backslash-continued lines:
    #          sed -e ':x /\\$/ { N; s/\\\n//g ; bx }'
    #          #TODO: The above requires gnu sed.
    #          #      non-gnu seds need newlines after ':' and 'b'
    #
    echo "${1}" \
        | tac | rev  \
        | sed -e ':x /:[ \t]*$/ { N; s/:[ \t]*\n//g ; bx }' \
        | tac  | rev  \
        | trim_to_bar_filter
}

trim_to_mark4() {
    # Based on https://www.gnu.org/software/sed/manual/html_node/Joining-lines.html
    # Join lines that start with whitespace (e.g SMTP headers):
    #  GNU sed: sed -E ':a ; $!N ; s/\n\s+/ / ; ta ; P ; D'
    #  A portable (non-gnu) variation: sed -e :a -e '$!N;s/\n  */ /;ta' -e 'P;D'
    #
    #
    echo "${1}" \
        | sed -e :a -e '$!N;s/\n[ \t]*://;ta' -e 'P;D' \
        | trim_to_bar_filter
}

#
#  Join lines starting with /[ \t]*:/ to the previous line.
#
ws_colon_is_continuation_filter() {
    # Based on https://www.gnu.org/software/sed/manual/html_node/Joining-lines.html
    # Join lines that start with whitespace (e.g SMTP headers):
    #  GNU sed: sed -E ':a ; $!N ; s/\n\s+/ / ; ta ; P ; D'
    #  A portable (non-gnu) variation: sed -e :a -e '$!N;s/\n  */ /;ta' -e 'P;D'
    #
    sed -e :a -e '$!N;s/\n[ \t]*://;ta' -e 'P;D'
}

trim_to_mark5() {
    echo "${1}" \
        | ws_colon_is_continuation_filter \
        | trim_to_bar_filter
}


S="|abc
   |def
   :20
   :19
   :18
   :17
   :16
   :15
   :14
   :13
   :12
   :11
   :10
   :9
   :8
   :7
   :6
   :5
   :4
   :3
   :2
   :1
   |mno"

echo -e "\ntrim_to_mark2"
trim_to_mark2 "${S}" | showSpaces

echo -e "\ntrim_to_mark3 works with GNU sed"
trim_to_mark3 "${S}" | showSpaces

echo -e "\ntrim_to_mark4 works"
trim_to_mark4 "${S}" | showSpaces

echo -e "\ntrim_to_mark5 works"
trim_to_mark5 "${S}" | showSpaces

echo 
echo "Q: What if first line is a continuation?"
echo "A: That line is left as is."
trim_to_mark5 " : ${S}" | showSpaces

echo 
echo "Q: What if last line is a continuation?"
echo "A: That line is joined to the previous one."
NEWLINE=$'\n'
trim_to_mark5 "${S}${NEWLINE}  :end" | showSpaces

echo 
echo "Q: What if we have multiple colons?"
echo "A: Only the first colon is removed, OK."
NEWLINE=$'\n'
trim_to_mark5 "a${NEWLINE} : : : b" | showSpaces



echo  "$(trim_to_mark5 \
            "|waitforlogentry(): application:
             : Timeout waiting for entry \"{keyword}\" in {logfile_basename}
             |  Last lines of {logfile_basename}:
             |")${NEWLINE}$(printf "%s\n" "Line1" "Line2" )"
