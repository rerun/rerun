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
DESCRIPTION=
INTERPRETER=bash
EOF
}

after() {
    rm -r $RERUN_MODULES/freddy
}

validate() {
    test -d $RERUN_MODULES/freddy/commands/dance
    test -f $RERUN_MODULES/freddy/commands/dance/metadata
    .  $RERUN_MODULES/freddy/commands/dance/metadata
    test -n "$NAME" -a $NAME = dance 
    test -n "$DESCRIPTION" -a "$DESCRIPTION" = "tell freddy to dance"
    test -f $RERUN_MODULES/freddy/commands/dance/script
    test -f $RERUN_MODULES/freddy/tests/functions.sh
    test -f $RERUN_MODULES/freddy/tests/dance-1-test.sh
    grep -q '[[ -f ./functions.sh ]] && . ./functions.sh' \
        $RERUN_MODULES/freddy/tests/dance-1-test.sh
}


# The Plan
# --------

describe "add-command"


it_runs_interactively() {
    rerun stubbs:add-command --module freddy <<EOF
dance
tell freddy to dance
EOF

    validate
}

it_runs_fully_optioned() {
    rerun stubbs:add-command --module "freddy" \
        --command dance --description "tell freddy to dance"

    validate
}

