#!/usr/bin/env roundup
#

# Let's get started
# -----------------
unset RERUN_COLORS
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

describe "rerun(4) Use an answer file"

it_fails_with_missing_answers_file() {
    # Check for expected error message.
    rerun --answers 2>&1 | grep "SYNTAX: option requires argument: --answers"

    # Check for expected error message.
    rerun --answers foo 2>&1 | grep "SYNTAX: answers file not found: foo"
}

it_overrides_option_default() {
    modules=$(mktemp -d "/tmp/rerun.modules.XXXXX")
    OUT=$modules/out.txt
    cat >$modules/answers  <<EOF
JUMPS=$$
EOF

    make_freddy $modules
    rerun --answers $modules/answers -M $modules freddy:dance > $OUT
    head -1 $OUT | grep -q "jumps ($$)" $OUT
    rm $OUT
}

it_ignores_unrecognized_answers() {
    modules=$(mktemp -d "/tmp/rerun.modules.XXXXX")
    OUT=$modules/out.txt
    cat >$modules/answers  <<EOF
BOGUS=blar
PHONY=ralb
EOF

    make_freddy $modules
    rerun --answers $modules/answers -M $modules freddy:dance > $OUT
    head -1 $OUT | grep -q "jumps (3)" $OUT
    rm $OUT
}

