#!/usr/bin/env roundup
#

# Let's get started
# -----------------
unset RERUN_COLOR
unset RERUN_MODULES

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


# The Plan
# --------

describe "rerun(2) Use external module directory"

it_fails_with_invalid_modules_dir() {
    # Check for expected error message.
    rerun -M /garbage/path 2>&1 | \
        grep "ERROR: RERUN_MODULES does not contain any valid directories: /garbage/path"
}

it_fails_with_invalid_modules_dir_with_multiple_entries() {
    # Check for expected error message.
    rerun -M /garbage/path:/another/garbage/path 2>&1 | \
        grep "ERROR: RERUN_MODULES does not contain any valid directories: /garbage/path"
}

it_displays_modules_when_no_arguments_single_path() {
    modules=$(mktemp -d "/tmp/rerun.modules.XXXXX")
    OUT=$modules/out.txt
    make_freddy $modules
    rerun -M $modules > $OUT
    head -1 $OUT | grep -q "Available modules" $OUT
    rm ${OUT}
    rm -rf ${modules}/freddy
    rmdir ${modules}
}

it_displays_modules_when_no_arguments_multiple_paths() {
    modules1=$(mktemp -d "/tmp/rerun.modules.XXXXX")
    modules2=$(mktemp -d "/tmp/rerun.modules.XXXXX")
    OUT=$modules1/out.txt
    make_freddy $modules1
    make_freddy $modules2
    rerun -M $modules1:$modules2 > $OUT
    head -1 $OUT | grep -q "Available modules" $OUT
    rm ${OUT}
    rm -rf ${modules1}/freddy
    rmdir ${modules1}
    rm -rf ${modules2}/freddy
    rmdir ${modules2}
}

it_displays_command_listing_single_path() {
    modules=$(mktemp -d "/tmp/rerun.modules.XXXXX")
    OUT=$modules/out.txt
    make_freddy $modules
    rerun -M $modules freddy > $OUT
    head -1 $OUT | grep -q "Available commands in module"
    grep -q 'study: "tell freddy to study"' $OUT
    grep -q '\[ --subject\|-s <math>]: "subject to study"' $OUT
    rm ${OUT}
    rm -rf ${modules}/freddy
    rmdir ${modules}
}

it_displays_command_listing_multiple_path() {
    modules1=$(mktemp -d "/tmp/rerun.modules.XXXXX")
    modules2=$(mktemp -d "/tmp/rerun.modules.XXXXX")
    OUT=$modules1/out.txt
    make_freddy $modules1
    make_freddy $modules2
    mv $modules1/freddy $modules1/berrie
    rerun -M $modules1:$modules2 freddy > $OUT
    head -1 $OUT | grep -q "Available commands in module"
    grep -q 'study: "tell freddy to study"' $OUT
    grep -q '\[ --subject\|-s <math>]: "subject to study"' $OUT
    rm ${OUT}
    rerun -M $modules1:$modules2 berrie > $OUT
    head -1 $OUT | grep -q "Available commands in module"
    grep -q 'study: "tell freddy to study"' $OUT
    grep -q '\[ --subject\|-s <math>]: "subject to study"' $OUT
    rm ${OUT}
    rm -rf ${modules2}/freddy
    rmdir ${modules2}
    rm -rf ${modules1}/berrie
    rmdir ${modules1}
}

it_runs_command_without_options() {
    modules=$(mktemp -d "/tmp/rerun.modules.XXXXX")
    make_freddy $modules
    out=$(rerun -M $modules freddy:study)
    test "$out" = "studying (math)"
    rm -rf ${modules}/freddy
    rmdir ${modules}
}

it_runs_command_with_option() {
    modules=$(mktemp -d "/tmp/rerun.modules.XXXXX")
    make_freddy $modules
    out=$(rerun -M $modules freddy:study --subject locking)
    test "$out" = "studying (locking)"
    out=$(rerun -M $modules freddy:study -s math)
    test "$out" = "studying (math)"
    rm -rf ${modules}/freddy
    rmdir ${modules}
}


