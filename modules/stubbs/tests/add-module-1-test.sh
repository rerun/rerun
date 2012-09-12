#!/usr/bin/env roundup
#

# Let's get started
# -----------------

# Helpers
# ------------

rerun() {
    command $RERUN -M $RERUN_MODULES "$@"
}

validate() {
    test -f $RERUN_MODULES/freddy/metadata
    .  $RERUN_MODULES/freddy/metadata
    test -n "$NAME" -a $NAME = freddy 
    test -n "$DESCRIPTION" -a "$DESCRIPTION" = "A dancer in a red beret and matching suspenders"
}

# The Plan
# --------

describe "stubbs:add-module"


it_runs_interactively() {
    rerun stubbs:add-module <<EOF
freddy
A dancer in a red beret and matching suspenders
EOF

    validate

}

it_runs_fully_optioned() {
    rerun stubbs:add-module --module "freddy" \
        --description "A dancer in a red beret and matching suspenders"
    
    validate
}

