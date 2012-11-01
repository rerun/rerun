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
    mkdir -p $RERUN_MODULES/freddy
    cat > $RERUN_MODULES/freddy/metadata <<EOF
NAME=freddy
EOF
    mkdir -p $RERUN_MODULES/freddy/commands/dance
    cat > $RERUN_MODULES/freddy/commands/dance/metadata <<EOF
NAME=dance
OPTIONS=
EOF
}

after() {
    #rm -r $RERUN_MODULES/freddy
    :
}

validate() {
    #
    # Check the metadata file
    test -f $RERUN_MODULES/freddy/options/jumps/metadata
    .  $RERUN_MODULES/freddy/options/jumps/metadata
    test -n "$NAME" -a $NAME = jumps 
    test -n "$DESCRIPTION" -a "$DESCRIPTION" = "jump #num times"
    #
    # Check the command's option assignment
    OPTIONS=$(.  $RERUN_MODULES/freddy/commands/dance/metadata; echo $OPTIONS)
    test -n "$OPTIONS"
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

it_exports_option_variable() {
    rerun stubbs:add-option --module freddy --command dance \
        --option jumps --description "jump #num times" --required true \
        --default 3 --export true
    rerun stubbs:add-option --module freddy --command dance \
        --option height --description "jump #height" --required false \
        --default 3 --export false

    validate
    # Check the option metadata
    grep "EXPORT=true"  $RERUN_MODULES/freddy/options/jumps/metadata
    # Check the option parser
    grep '^export JUMPS$' $RERUN_MODULES/freddy/commands/dance/options.sh
    grep -v '^export HEIGHT$' $RERUN_MODULES/freddy/commands/dance/options.sh
}