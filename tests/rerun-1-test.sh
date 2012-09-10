#!/usr/bin/env roundup
#

# Let's get started
# -----------------
unset RERUN_COLORS

# Helpers
# ------------
source ./functions.sh || { echo "Failed loading test functions" ; exit 2 ; }

rerun() {
    command $RERUN "$@"
}



# The Plan
# --------

describe "rerun(1) Basic sanity tests"



it_displays_help() {
    help=$(rerun -help)
    test -n "$help"
}

it_displays_usage() {
    usage=$(rerun -help|grep ^Usage)
    test "$usage" = "Usage: rerun [-h][-v][-V] [-M <dir>] [-L <dir>] [--replay <file>] [module:[command [options]]]"
}

it_displays_version_and_license() {
    rinfo=( $(rerun -help|grep Version:) )
    test "${rinfo[1]}" = "Version:"
    test "${rinfo[2]}" = "v0.1."
    test "${rinfo[3]}" = "License:"
    test "${rinfo[4]}" = "Apache"
}

it_displays_modules_when_no_arguments() {
    OUT=$(mktemp "/tmp/rerun.test.XXXXX")
    make_freddy $RERUN_MODULES
    rerun > $OUT
    head -1 $OUT | grep -q "Available modules" $OUT
    rm $OUT
}

it_displays_command_listing() {
    OUT=$(mktemp "/tmp/rerun.test.XXXXX")
    make_freddy $RERUN_MODULES
    rerun freddy > $OUT
    head -1 $OUT | grep -q "Available commands in module"
    grep -q 'dance: "tell freddy to dance"' $OUT
    grep -q '\[ -j|--jumps]: "jump #num times"' $OUT
    rm $OUT
}

it_runs_command_without_options() {
    OUT=$(mktemp "/tmp/rerun.test.XXXXX")
    make_freddy $RERUN_MODULES
    out=$(rerun freddy:dance)
    test "$out" = "jumps (3)"
    rm $OUT
}

it_runs_command_with_option() {
    make_freddy $RERUN_MODULES
    out=$(rerun freddy:dance --jumps 5)
    test "$out" = "jumps (5)"
    out=$(rerun freddy:dance -j $$)
    test "$out" = "jumps ($$)"
}


it_runs_command_with_verbosity() {
    OUT=$(mktemp "/tmp/rerun.test.XXXXX")
    make_freddy $RERUN_MODULES
    rerun -v freddy:dance 2> $OUT
    grep -q "#!/usr/bin/env bash" $OUT
    grep -q "+ echo 'jumps (3)'" $OUT
    rm $OUT
}

it_runs_command_with_V_option() {
    OUT=$(mktemp "/tmp/rerun.test.XXXXX")
    make_freddy $RERUN_MODULES
    rerun -V freddy:dance 2> $OUT
    grep -q "+ OPT=freddy:dance" $OUT
    grep -q "+ exit 0" $OUT
    rm $OUT
}