#!/bin/bash

set_up() {
 X11DOCKER_TESTING=1
 . ../x11docker
}

set_up

#
# The Open Group Base Specifications Issue 8: it is
#     implementation-defined whether "\?", "\+", and "\|"
#     each match the literal character '?', '+', or '|',
#     respectively, or behave as described for the ERE
#     special characters
#
# The Open Group Base Specifications Issue 7: BRE does use '?' or '+', but has '{0,}' and '{1,}'
#

get_sed_zero_or_one_BRE(){
    local mysed="${1:-MISSING-sed}"
    local res=''
    if  [ "$(echo "abc" | $mysed -e 's|bc?|bd|' )" = "abd" ] ;
    then res='?'
    elif [ "$(echo "abc" | $mysed -e 's|bc\?|bd|' )" = "abd" ] ;
    then res='?'
    elif [ "$(echo "abc" | $mysed -e 's|bc{0,1}|bd|' )" = "abd" ] ;
    then res='{0,1}'
    elif [ "$(echo "abc" | $mysed -e 's|bc\{0,1\}|bd|' )" = "abd" ] ;
    then res='\{0,1\}'
    else error "Could not determine sed_zero_or_one_BRE"
    fi
    echo "${res}"
}


#
get_sed_one_or_more_BRE() {
    local mysed="${1:-MISSING-sed}"
    local res=''
    if   [ "$(echo "abcc" | $mysed -e 's|bc+|bd|' )" = "abd" ] ;
    then res='+'
    elif [ "$(echo "abcc" | $mysed -e 's|bc\+|bd|' )" = "abd" ] ;
    then res='\+'
    else error "Could not determine sed_one_or_more_BRE"
    fi
    echo "${res}"
}


get_sed_alt_BRE() {
    local mysed="${1:-MISSING-sed}"
    local res=''
    if   [ "$(echo "abc" | $mysed -e 's/\(a|c\)/x/g' )" = "xbx" ] ;
    then res='|'
    elif [ "$(echo "abc" | $mysed -e 's/\(a\|c\)/x/g' )" = "xbx" ] ;
    then res='\|'
    else error "Could not determine sed_alt_BRE"
    fi
    echo "${res}"
}

get_sed_question_mark_BRE() {
    local mysed="${1:-MISSING-sed}"
    local res='[?]'
    if   [ "$(echo "a?c" | $mysed -e 's/a[?]/ax/g' )" = "axc" ] ;
    then res='[?]'
    else error "Could not determine sed_question_mark_BRE"
    fi
    echo "${res}"
}

get_sed_plus_BRE() {
    local mysed="${1:-MISSING-sed}"
    local res='[+]'
    if   [ "$(echo "a+c" | $mysed -e 's/a[+]/ax/g' )" = "axc" ] ;
    then res='[+]'
    else error "Could not determine sed_plus_BRE"
    fi
    echo "${res}"
}

get_sed_has_E() {
    local mysed="${1:-MISSING-sed}"
    local res='no'
    if   [ "$(echo "abcbbdbbbe" | $mysed -E -e 's/(e|b+)/./g' )" = "a.c.d.." ] ;
    then res='yes'
    fi
    echo "${res}"
}

get_sed_has_i() {
    local mysed="${1:-MISSING-sed}"
    local tmp_file="$(basename $0 .sh).tmp"
    cat > "$tmp_file" <<EOF
apples
oranges
EOF
    $mysed -i -E -e 's/apple/Apple/g' "$tmp_file"
    if ! grep -q Apples "$tmp_file" ; then
        echo "sed -i did not edit the file" >&2
        echo "no"
        unlink "${tmp_file}"
        return 1
    fi
    if [ -e "${tmp_file}.bak" ]  ; then
        echo "sed -i created file.bak" >&2
        echo "no"
        unlink "${tmp_file}"
        unlink "${tmp_file}.bak"
        return 1
    fi
    if [ -e "${tmp_file}-E" ]  ; then
        echo "sed -i created file-Ek" >&2
        echo "no"
        unlink "${tmp_file}"
        unlink "${tmp_file}-E"
        return 1
    fi
    unlink "$tmp_file"
    echo "yes"
    return 0
}

sed_Modeline_test() {
    local mysed="${1:-MISSING-sed}"
    local Modeline='Modeline "1920x1200_60.00"  193.25  1920 2056 2256 2592  1200 1203 1209 1245 -hsync +vsync'
    local res=''
    local Modeline_ERE='^Modeline ["]([0-9]+x[0-9]+)(_[0-9.]+)?["]'
    # RE for the start of a Modeline.
    #    \1 yields size without quotes.
    #    \2 is "_60.00", the frequency prefixe with _ (May be empty if not present)
    #    The rest of the line left as is.
    #
    res="$( echo "$Modeline" | $mysed -E -e "s|${Modeline_ERE}|\"\\1\"|" )"
    # 'Modeline ' prefix and '_60.00' suffix of name removed
    local expected='"1920x1200"  193.25  1920 2056 2256 2592  1200 1203 1209 1245 -hsync +vsync'
    if [ "$res" = "$expected" ] ; then
        echo "PASS"
        return 1
    else
        echo "FAIL"
        return 0
    fi
}

sed_Screen_test() {
    local mysed="${1:-MISSING-sed}"
    local ERE1
    local Line
    local Maxxaxis Maxyaxis
    local Xrandroutput="$(trim_to_bar \
       '|Screen 0: minimum 8 x 8, current 1920 x 1200, maximum 32767 x 32767
        |DP1 disconnected (normal left inverted right x axis y axis)
        |HDMI1 disconnected (normal left inverted right x axis y axis)
        |HDMI2 connected 1920x1200+0+0 (normal left inverted right x axis y axis) 520mm x 330mm
        |   1920x1200     59.95*+
        |'
        )"
    # -------------------------
    ERE1="$(trim_to_mark \
          '|^Screen ([0-9]+):
           : minimum [0-9]+ x [0-9]+
           :, current ([0-9]+) x ([0-9]+)
           :, maximum [0-9]+ x [0-9]+$'
           )"
    Line="$( echo "$Xrandroutput" | grep -E -e "${ERE1}" | head -n1  )"
    Maxxaxis="$(echo "$Line" | $mysed -E -e "s|${ERE1}|\\2|" )" # 1920
    Maxyaxis="$(echo "$Line" | $mysed -E -e "s|${ERE1}|\\3|" )" # 1200
    # -------------------------
    if [ "$Maxxaxis" != "1920" ] ; then
        echo "sed_Screen_test() Maxxaxis is not 1920, it is '$Maxxaxis'" >&2
        echo FAIL
        return 1
    fi
    if [ "$Maxyaxis" != "1200" ] ; then
        echo "sed_Screen_test() Maxyaxis is not 1200" >&2
        echo FAIL
        return 1
    fi
    echo PASS
    return 0
}

sed_connected_test() {
    local mysed="${1:-MISSING-sed}"
    local ERE2 monitorname_ERE
    local Line
    local Maxxaxis Maxyaxis
    local Xrandroutput="$(trim_to_bar \
       '|Screen 0: minimum 8 x 8, current 1920 x 1200, maximum 32767 x 32767
        |DP1 disconnected (normal left inverted right x axis y axis)
        |HDMI1 disconnected (normal left inverted right x axis y axis)
        |HDMI2 connected 1920x1200+0+0 (normal left inverted right x axis y axis) 520mm x 330mm
        |   1920x1200     59.95*+
        |'
        )"
    #
    # ------------------------------------------------
    # monitorname_ERE='[^ ]+'
    monitorname_ERE='[A-Za-z][A-Za-z0-9-]*'
    #
    ERE2="^(${monitorname_ERE}) connected ([0-9]+)x([0-9]+)[+].*\$"
    Line="$( echo "$Xrandroutput" | grep -E -e "${ERE2}"  | head -n1  )"
    Maxxaxis="$(echo "$Line" | $mysed -E -e "s|${ERE2}|\\2|" )" # 1920
    Maxyaxis="$(echo "$Line" | $mysed -E -e "s|${ERE2}|\\3|" )" # 1200
    # ------------------------------------------------
    if [ "$Maxxaxis" != "1920" ] ; then
        echo "sed_connected_test() Maxxaxis is not 1920, it is '$Maxxaxis'" >&2
        echo FAIL
        return 1
    fi
    if [ "$Maxyaxis" != "1200" ] ; then
        echo "sed_connected_test() Maxyaxis is not 1200" >&2
        echo FAIL
        return 1
    fi
    echo PASS
    return 0
}

main() {

    for current_sed in "$(command -v sed)" "busybox sed" ; do

        echo
        printf "sed_command: \"%s\"\n"          "$current_sed"
        printf "sed_version: \"%s\"\n"          "$( $current_sed --version | head -n1 )"
        #
        local sed_zero_or_one_BRE
        sed_zero_or_one_BRE="$( get_sed_zero_or_one_BRE     "$current_sed" )"
        printf "\t sed_zero_or_one_BRE   = '%s'\n"   "$sed_zero_or_one_BRE"
        #
        local sed_one_or_more_BRE
        sed_one_or_more_BRE="$( get_sed_one_or_more_BRE     "$current_sed" )"
        printf "\t sed_one_or_more_BRE   = '%s'\n"   "$sed_one_or_more_BRE"
        #
        local sed_alt_BRE
        sed_alt_BRE="$(         get_sed_alt_BRE             "$current_sed" )"
        printf "\t sed_alt_BRE           = '%s'\n"   "$sed_alt_BRE"
        #
        local sed_question_mark_BRE
        sed_question_mark_BRE="$(get_sed_question_mark_BRE  "$current_sed" )"
        printf "\t sed_question_mark_BRE = '%s'\n"   "$sed_question_mark_BRE"
        #
        local sed_plus_BRE
        sed_plus_BRE="$(         get_sed_plus_BRE           "$current_sed" )"
        printf "\t sed_plus_BRE          = '%s'\n"   "$sed_plus_BRE"
        #
        local sed_has_E
        sed_has_E="$(            get_sed_has_E              "$current_sed" )"
        printf "\t sed -E                = '%s'\n"   "$sed_has_E"
        #
        local sed_has_i
        sed_has_i="$(            get_sed_has_i              "$current_sed" )"
        printf "\t sed -i                = '%s'\n"   "$sed_has_i"
        #
        local sed_Modeline_result
        sed_Modeline_result="$(  sed_Modeline_test          "$current_sed" )"
        printf "\t sed_Modeline_result   = '%s'\n"   "$sed_Modeline_result"
        #
        local sed_Screen_result
        sed_Screen_result="$(    sed_Screen_test            "$current_sed" )"
        printf "\t sed_Screen_result     = '%s'\n"   "$sed_Screen_result"
        #
        local sed_connected_result
        sed_connected_result="$(    sed_connected_test            "$current_sed" )"
        printf "\t sed_connected_result  = '%s'\n"   "$sed_connected_result"
        #
    done

}

main

# Result: We probably only use a GNU sed version,
#         - Can use -E
#         - Can use -i
