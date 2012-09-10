#!/usr/bin/env roundup
#

# Let's get started
# -----------------

# Helpers
# ------------

rerun() {
    command $RERUN -M $RERUN_MODULES "$@"
}

after() {
    [ -d $RERUN_MODULES ] && rm -rf $RERUN_MODULES/freddy
}

# The Plan
# --------

describe "stubbs functional tests"

it_builds_a_functional_module() {
    # Create module: freddy
    rerun stubbs:add-module --module "freddy" \
        --description "A dancer in a red beret and matching suspenders"
    
    # Create command: freddy:dance
    rerun stubbs:add-command --module "freddy" \
        --command dance --description "tell freddy to dance"

    # Create option: freddy:dance --jumps <3>
    rerun stubbs:add-option --module freddy --command dance \
        --option jumps --description "jump #num times" --required true --default 3    

    # ... Rewrite the handler to echo option value
    hdler=$RERUN_MODULES/freddy/commands/dance/default.sh
    cat  $hdler | sed 's/\# Your implementation goes here./echo "jumps ($JUMPS)"/' > /tmp/default.sh$$
    mv /tmp/default.sh$$ $hdler 

    # Run the tests
    test "$(rerun freddy:dance)" = "jumps (3)"
    test "$(rerun freddy:dance --jumps $$)" = "jumps ($$)"
}
