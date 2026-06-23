#
# This was an attempt to capture stdout, stderr, exitcode.
# With shunit2, exit in the tested function was not properly detected.
#
# on_exit(){
#    local code="${?}"
#    [[ "${code}" -ne 0 ]] && {
#        printf "\n---\n%s\n%s\n" \
#               "on_exit: FAILED (exit ${code})" \
#               "cmd: ${CURRENT_COMMAND:-nocmd}" \
#               >> captured.yaml
#    }
# }
# 
# #
# # declare -A res
# # capture res cmd args
# #
# # Runs `cmd args`, captures exitCode, stderr and stdout to
# #       res[exitCode] res[stdout] and res[stderr]
# #
# capture() {
#     # $1 should name an associative array
#     declare -n result="$1"
#     shift
#     #
#     # Run cmd and capture its exitCode, stdout, stderr
#     #
#     local tmpfile1="$(mktemp -t file_1_XXXXXX)"
#     local tmpfile2="$(mktemp -t file_2_XXXXXX)"
#     #
#     trap 'on_exit' EXIT
#     CURRENT_COMMAND="$*"
#     echo -n > captured.yaml
#     "${@}"  2>"$tmpfile2" 1>"$tmpfile1"
#     result[exitCode]="$?"
#     trap - EXIT
#     unset CURRENT_COMMAND
#     #
#     result[stdout]="$(< "$tmpfile1")"
#     result[stderr]="$(< "$tmpfile2")"
#     # trap '' EXIT
#     unlink "$tmpfile1"
#     unlink "$tmpfile2"
#     printf "\n---\ncmd: %s\n" "$*" >> captured.yaml
#     printf "exitCode: %s\nstdout: |\n%s\nstderr: |\n%s\n" \
#            "${result[exitCode]}" \
#            "${result[stdout]}"   \
#            "${result[stderr]}"   \
#            >> captured.yaml
#     return 0
# }
# 
# #
# # cmd is run in a subshell (var changes are lost)
# capture_subshell() {
#     ( capture "${@}" )
#     return 0
#     #    # $1 should name an associative array
#     #    declare -n result="$1"
#     #    shift
#     #    #
#     #    # Run cmd and capture its exitCode, stdout, stderr
#     #    #
#     #    local tmpfile1="$(mktemp -t file_1_XXXXXX)"
#     #    local tmpfile2="$(mktemp -t file_2_XXXXXX)"
#     #    local tmpfile3="$(mktemp -t file_3_XXXXXX)"
#     #    ( "${@}"  2>"$tmpfile2" 1>"$tmpfile1"; echo $? >"$tmpfile3" )
#     #    result[subshellExitCode]=$?
#     #    result[exitCode]="$(< "$tmpfile3")"
#     #    result[stdout]="$(< "$tmpfile1")"
#     #    result[stderr]="$(< "$tmpfile2")"
#     #    unlink "$tmpfile1"
#     #    unlink "$tmpfile2"
#     #    unlink "$tmpfile3"
#     #    return 0
# }
# 
# 
# f1() {
#     echo "Good $1"
#     echo "Bad $2" >&2
#     return 13
# }
# 
# test_capture() {
#     declare -A res
#     capture res f1 aha jaj
#     assertEquals 13         "${res[exitCode]}"
#     assertEquals "Good aha" "${res[stdout]}"
#     assertEquals "Bad jaj"  "${res[stderr]}"
# }
