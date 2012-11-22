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
    test -n "$NAME" -a "$NAME" = freddy 
    test -n "$DESCRIPTION" -a "$DESCRIPTION" = "A dancer in a red beret and matching suspenders"
    test -n "$META_MODULE" -a "$META_MODULE" = "bash"
    test -n "$SHELL" -a "$SHELL" = "bash"
    grep '^VERSION=' $RERUN_MODULES/freddy/metadata
    grep '^REQUIRES=' $RERUN_MODULES/freddy/metadata

}

# The Plan
# --------

describe "add-module"


it_runs_interactively() {
    rerun stubbs:add-module <<EOF
freddy
A dancer in a red beret and matching suspenders

EOF

    validate

}

it_runs_fully_optioned() {
    rerun stubbs:add-module --module "freddy" \
        --description "A dancer in a red beret and matching suspenders" \
        --meta-module bash

    validate
}

