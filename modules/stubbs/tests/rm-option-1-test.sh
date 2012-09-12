#!/usr/bin/env roundup
#

# Let's get started
# -----------------

# Helpers
# -------

# A helper to run rerun.
rerun() {
    command $RERUN -M $RERUN_MODULES "$@"
}

# Mock a command and create an option.
before() {
    mkdir -p $RERUN_MODULES/freddy/commands/dance
    rerun stubbs:add-option --module freddy --command dance \
        --option jumps --desc "number of times to jump" \
        --default 1 --required false
}

# Remove the mock module directory.
after() {
    rm -r $RERUN_MODULES/freddy
}

# Check the option metadata file exists and 
# the parser no longer contains the option.
validate() {
    ! test -f $RERUN_MODULES/freddy/commands/dance/jumps.option
    parser=$RERUN_MODULES/freddy/commands/dance/options.sh
    test -f $parser
    ! grep -q "\-j\|\--jumps)" $parser 
    ! grep -q '[ -z "$JUMPS" ] && JUMPS="3"' $parser
    ! grep -q '"missing required option: --jumps"' $parser
}

# The Plan
# --------

describe "stubbs:rm-option"

# Run it in interactive mode.
it_runs_interactively() {
    rerun stubbs:rm-option --module freddy --command dance<<EOF
jumps
EOF
    validate

}

# Run the command with all options.
it_runs_fully_optioned() {
    rerun stubbs:rm-option --module freddy --command dance --option jumps
    validate
}
