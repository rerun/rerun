#!/usr/bin/env roundup
#

# Let's get started
# -----------------
unset RERUN_COLOR


# Helpers
# ------------
for i in ./functions.sh ../tests/functions.sh `dirname $1`/functions.sh `dirname $0`/functions.sh
do
  if [ -r ${i} ]; then
    . ${i} || { echo "Failed loading test functions" ; exit 2 ; }
    break
  fi
done

rerun() {
    command $RERUN "$@"
}

before() {
    [ -z "$RERUN_MODULES" ] && die "RERUN_MODULES not set"
}

# The Plan
# --------

describe "rerun(1) Basic sanity tests"



it_displays_help() {
    ! help=$(rerun -help 2>&1)
    test -n "$help"
}

it_displays_usage() {
    usage=$(rerun -help 2>&1 |grep '^usage:')
    test "$usage" = 'usage: rerun [-h][-G][-v][-V][--version] [--loglevel <>] [-M <dir>] [--answers|-A <file>] [module:[command [options]]]'
}

it_displays_version_and_license() {
    rinfo=( $(rerun -help 2>&1 | grep Version:) )
    test "${rinfo[0]}" = "Version:"
    test "${rinfo[1]}" = "1.3.6."
    test "${rinfo[2]}" = "License:"
    test "${rinfo[3]}" = "Apache"
}

it_displays_modules_when_no_arguments() {
    . $RERUN
    OUT=$(mktemp "/tmp/rerun.test.XXXXX")
    make_freddy $(rerun_module_path_elements $RERUN_MODULES | head -1)
    rerun > $OUT
    head -1 $OUT | grep -q "Available modules" $OUT
    rm ${OUT}
}

it_fails_with_nonexistent_module() {
    OUT=$(mktemp "/tmp/rerun.test.XXXXX")
    (rerun phony -msg blar 2>&1) |tee $OUT
    test ${PIPESTATUS[0]} = 2; # syntax errors exit with 2
    grep 'module not found: "phony -msg blar"' $OUT
    rm ${OUT}
}


it_displays_command_listing() {
    . $RERUN
    OUT=$(mktemp "/tmp/rerun.test.XXXXX")
    make_freddy $(rerun_module_path_elements $RERUN_MODULES | head -1)
    rerun freddy > $OUT
    head -1 $OUT | grep -q "Available commands in module"
    grep -q 'dance: "tell freddy to dance"' $OUT
    grep -q '\[ --jumps\|-j <3>]: "jump #num times"' $OUT
    rm ${OUT}
}

it_runs_command_without_options() {
    . $RERUN
    make_freddy $(rerun_module_path_elements $RERUN_MODULES | head -1)
    out=$(rerun freddy:dance)
    test "$out" = "jumps (3)"
}

it_runs_command_with_option() {
    . $RERUN
    make_freddy $(rerun_module_path_elements $RERUN_MODULES | head -1)
    out=$(rerun freddy:dance --jumps 5)
    test "$out" = "jumps (5)"
    out=$(rerun freddy:dance -j $$)
    test "$out" = "jumps ($$)"
}


it_runs_command_with_verbosity() {
    . $RERUN
    OUT=$(mktemp "/tmp/rerun.test.XXXXX")
    make_freddy $(rerun_module_path_elements $RERUN_MODULES | head -1)
    rerun -v freddy:dance 2> $OUT
    grep -q "+ source" $OUT
    grep -q "+ echo 'jumps (3)'" $OUT
    rm ${OUT}
}

it_runs_command_with_V_option() {
    . $RERUN
    OUT=$(mktemp "/tmp/rerun.test.XXXXX")
    make_freddy $(rerun_module_path_elements $RERUN_MODULES | head -1)
    rerun -V freddy:dance 2> $OUT
    grep -q "+ OPT=freddy:dance" $OUT
    grep -q "+ exit 0" $OUT
    rm ${OUT}
}
