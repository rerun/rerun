#!/usr/bin/env roundup
#

# Let's get started
# -----------------
unset RERUN_COLORS

# Helpers
# ------------


. ./functions.sh || { echo "Failed loading test functions" ; exit 2 ; }

rerun() {
    command $RERUN "$@"
}

before() {
    [ -z "$RERUN_MODULES" ] && die "RERUN_MODULES not set"
    OUT=$(mktemp "/tmp/rerun.test.XXXXX")
}

after() {
    rm $OUT
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
    test "$usage" = 'usage: rerun [-h][-v][-V][--version] [-M <dir>] [--answer <file>] [module:[command [options]]]'
}

it_displays_version_and_license() {
    rinfo=( $(rerun -help|grep Version:) )
    test "${rinfo[1]}" = "Version:"
    test "${rinfo[2]}" = "1.0.0."
    test "${rinfo[3]}" = "License:"
    test "${rinfo[4]}" = "Apache"
}

it_displays_modules_when_no_arguments() {
    make_freddy $RERUN_MODULES
    rerun > $OUT
    head -1 $OUT | grep -q "Available modules" $OUT
}

it_fails_with_nonexistent_module() {
    (rerun phony -msg blar 2>&1) |tee $OUT
    test ${PIPESTATUS[0]} = 2; # syntax errors exit with 2
    grep 'module not found: "phony -msg blar"' $OUT
}


it_displays_command_listing() {
    make_freddy $RERUN_MODULES
    rerun freddy > $OUT
    head -1 $OUT | grep -q "Available commands in module"
    grep -q 'dance: "tell freddy to dance"' $OUT
    grep -q '\[ --jumps\|-j <3>]: "jump #num times"' $OUT
}

it_runs_command_without_options() {
    make_freddy $RERUN_MODULES
    out=$(rerun freddy:dance)
    test "$out" = "jumps (3)"
}

it_runs_command_with_option() {
    make_freddy $RERUN_MODULES
    out=$(rerun freddy:dance --jumps 5)
    test "$out" = "jumps (5)"
    out=$(rerun freddy:dance -j $$)
    test "$out" = "jumps ($$)"
}


it_runs_command_with_verbosity() {
    make_freddy $RERUN_MODULES
    rerun -v freddy:dance 2> $OUT
    grep -q "+ source" $OUT
    grep -q "+ echo 'jumps (3)'" $OUT
}

it_runs_command_with_V_option() {
    make_freddy $RERUN_MODULES
    rerun -V freddy:dance 2> $OUT
    grep -q "+ OPT=freddy:dance" $OUT
    grep -q "+ exit 0" $OUT
}
