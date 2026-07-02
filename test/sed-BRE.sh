#!/bin/bash

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


for current_sed in "$(command -v sed)" "busybox sed" ; do

    echo
    sed_zero_or_one_BRE="$( get_sed_zero_or_one_BRE     "$current_sed" )"
    sed_one_or_more_BRE="$( get_sed_one_or_more_BRE     "$current_sed" )"
    sed_alt_BRE="$(         get_sed_alt_BRE             "$current_sed" )"
    sed_question_mark_BRE="$(get_sed_question_mark_BRE  "$current_sed" )"
    sed_plus_BRE="$(         get_sed_plus_BRE           "$current_sed" )"
    sed_has_E="$(            get_sed_has_E              "$current_sed" )"
    sed_has_i="$(            get_sed_has_i              "$current_sed" )"
    sed_Modeline_result="$(  sed_Modeline_test          "$current_sed" )"
    printf "sed_command: \"%s\"\n"          "$current_sed"
    printf "sed_version: \"%s\"\n"          "$( $current_sed --version | head -n1 )"
    printf "\t sed_zero_or_one_BRE   = '%s'\n"   "$sed_zero_or_one_BRE"
    printf "\t sed_one_or_more_BRE   = '%s'\n"   "$sed_one_or_more_BRE"
    printf "\t sed_alt_BRE           = '%s'\n"   "$sed_alt_BRE"
    printf "\t sed_question_mark_BRE = '%s'\n"   "$sed_question_mark_BRE"
    printf "\t sed_plus_BRE          = '%s'\n"   "$sed_plus_BRE"
    printf "\t sed -E                = '%s'\n"   "$sed_has_E"
    printf "\t sed -i                = '%s'\n"   "$sed_has_i"
    printf "\t sed_Modeline_result   = '%s'\n"   "$sed_Modeline_result"

done

# Result: We probably only use a GNU sed version,
#         - Can use -E
#         - Can use -i
