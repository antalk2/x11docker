
#
# This file is executed using different shells, from local.sh
#

## https://github.com/cloudstreet-dev/POSIX-Shell-Scripting/blob/main/12-portability.md

# Check shell features
check_features() {
    # echo
    # echo "check_features"
    # echo
    #
    # Test for local variables
    printf "%-40s " "Does shell support 'local'?"
    if (eval 'f() { local x=1; }; f' 2>/dev/null);
    then  echo yes
    else  echo no
    fi

    # Test for arrays (not POSIX)
    printf "%-40s " "Does shell supports arrays? "
    if (eval 'x=(1 2 3)' 2>/dev/null);
    then  echo yes
    else  echo no
    fi

    # Test for [[ ]]
    printf "%-40s " 'Does shell support `[[ ]]`?'
    if (eval '[[ 1 = 1 ]]' 2>/dev/null);
    then echo yes
    else echo no
    fi
}

check_features
