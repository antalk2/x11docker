#!/bin/bash



#
# Q: Does 'local x' inherit the value of x from its caller?
#

# tmp_sh="$(mktemp --suffix=.sh)"
tmp_sh="local-tmp.sh"

cat  > "$tmp_sh" <<"EOF"
f(){ local x y= z='f' ; echo "x_in_f '$x'" ; echo "y_in_f '$y'" ; echo "z_in_f '$z'" ; }
g(){ local x y z ; x="g" ; y="g"; z="g"; f ; }
g
EOF

echo "-- the_script ---"
cat "$tmp_sh"
echo "-----------------"

echo
echo "bash the_script"
bash "$tmp_sh"

echo
echo "dash the_script"
dash "$tmp_sh"

echo
echo "ash the_script"
ash "$tmp_sh"

echo
echo "sh the_script"
sh "$tmp_sh"

echo
echo "busybox sh the_script"
busybox sh "$tmp_sh"



unlink "$tmp_sh"


# Result:
#
# `local x` :
#       bash, busybox sh: ''
#       dash,ash,sh (-> dash) inherits value from g
#
# `local y=` :
#       bash, busybox sh, dash,ash,sh (-> dash): ''
#
# `local z='f'` :
#       bash, busybox sh, dash,ash,sh (-> dash): 'f'
#
#
# Summary: `local x`  is not portable accross these shells: some inherit, some reset the value.
#          `local x=` is     portable accross these shells,
#                     although shellcheck complains on `local x= y`
#          `local x=""` is portable and keeps shellcheck silent.
#
#    - No reliable way to inherit.
#    - Use `local x=""` to avoid inheriting.
#

test_file=local-check-features.sh

for s in bash dash ash sh 'busybox sh' ; do
    echo
    echo "--- $s $test_file ---"
    $s $test_file
done

#
# local is supported by:    bash dash ash sh 'busybox sh'
# arrays are supported by:  bash   -   -   -   -
# [[ ]] is supported by:    bash   -   -   -  'busybox sh'
#
