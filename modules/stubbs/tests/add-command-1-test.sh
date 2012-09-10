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
}

after() {
    rm -r $RERUN_MODULES/freddy
}

validate() {
    test -d $RERUN_MODULES/freddy/commands/dance
    test -f $RERUN_MODULES/freddy/commands/dance/metadata
    source  $RERUN_MODULES/freddy/commands/dance/metadata
    test -n "$NAME" -a $NAME = dance 
    test -n "$DESCRIPTION" -a "$DESCRIPTION" = "tell freddy to dance"
    test -f $RERUN_MODULES/freddy/commands/dance/default.sh
}


# The Plan
# --------

describe "stubbs:add-command"


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

