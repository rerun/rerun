#!/usr/bin/env roundup
#

# Let's get started
# -----------------

# Helpers
# ------------

rerun() {
    command $RERUN -M $RERUN_MODULES "$@"
}

before() {
    mkdir -p $RERUN_MODULES/freddy/commands/dance
}

after() {
    rm -r $RERUN_MODULES/freddy
}

validate() {
    #
    # Check the metadata file
    test -f $RERUN_MODULES/freddy/commands/dance/jumps.option
    .  $RERUN_MODULES/freddy/commands/dance/jumps.option
    test -n "$NAME" -a $NAME = jumps 
    test -n "$DESCRIPTION" -a "$DESCRIPTION" = "jump #num times"
    #
    # Check the option parser
    test -f $RERUN_MODULES/freddy/commands/dance/options.sh
    grep -q "\-j\|\--jumps)" $RERUN_MODULES/freddy/commands/dance/options.sh
    grep -q '[ -z "$JUMPS" ] && JUMPS="3"' $RERUN_MODULES/freddy/commands/dance/options.sh
    grep -q '"missing required option: --jumps"' $RERUN_MODULES/freddy/commands/dance/options.sh
    return $?
}

# The Plan
# --------

describe "add-option"


it_runs_interactively() {
    rerun stubbs:add-option --module freddy --command dance <<EOF
jumps
jump #num times
1
3
EOF
    validate

}

it_runs_fully_optioned() {
    rerun stubbs:add-option --module freddy --command dance \
        --option jumps --description "jump #num times" --required true --default 3

    validate
}
