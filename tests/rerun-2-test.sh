#!/usr/bin/env roundup
#

# Let's get started
# -----------------
unset RERUN_COLORS
unset RERUN_MODULES

# Helpers
# ------------
. ./functions.sh || { echo "Failed loading test functions" ; exit 2 ; }

rerun() {
    command $RERUN "$@"
}


# The Plan
# --------

describe "rerun(2) Use external module directory"

it_fails_with_invalid_modules_dir() {
    # Check for expected error message.
    rerun -M /garbage/path 2>&1 | \
        grep "ERROR: RERUN_MODULES directory not found or does not exist: /garbage/path"
}

it_displays_modules_when_no_arguments() {
    modules=$(mktemp -d "/tmp/rerun.modules.XXXXX")
    OUT=$modules/out.txt
    make_freddy $modules
    rerun -M $modules > $OUT
    head -1 $OUT | grep -q "Available modules" $OUT
    rm $OUT
}

it_displays_command_listing() {
    modules=$(mktemp -d "/tmp/rerun.modules.XXXXX")
    OUT=$modules/out.txt
    make_freddy $modules
    rerun -M $modules freddy > $OUT
    head -1 $OUT | grep -q "Available commands in module"
    grep -q 'study: "tell freddy to study"' $OUT
    grep -q '\[ --subject|-s <math>]: "subject to study"' $OUT
}

it_runs_command_without_options() {
    modules=$(mktemp -d "/tmp/rerun.modules.XXXXX")
    OUT=$modules/out.txt
    make_freddy $modules
    out=$(rerun -M $modules freddy:study)
    test "$out" = "studying (math)"
}

it_runs_command_with_option() {
    modules=$(mktemp -d "/tmp/rerun.modules.XXXXX")
    OUT=$modules/out.txt
    make_freddy $modules
    out=$(rerun -M $modules freddy:study --subject locking)
    test "$out" = "studying (locking)"
    out=$(rerun -M $modules freddy:study -s math)
    test "$out" = "studying (math)"
}


