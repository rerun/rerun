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
   rm -rf $RERUN_MODULES/freddy
}

# The Plan
# --------

describe "functional: functional tests for a bash module"

it_builds_a_functional_module() {
    # Create module: freddy
    rerun stubbs:add-module --module "freddy" \
        --description "A dancer in a red beret and matching suspenders" \
        --interpreter bash
    
    # Create command: freddy:dance
    rerun stubbs:add-command --module "freddy" \
        --command dance --description "tell freddy to dance"

    commandScript=$RERUN_MODULES/freddy/commands/dance/script
    # Be sure the command script has execute bit set 
    test -x$commandScript
    
    # Create option: freddy:dance --jumps <3>
    rerun stubbs:add-option --module freddy --command dance \
        --option jumps --description "jump #num times" --required true --default 3    

    test -x$commandScript 
 
    # ... Rewrite the handler to echo option value
    cat  $commandScript | sed 's/\# Your implementation goes here./echo "jumps ($JUMPS)"/' > /tmp/script.$$
    mv /tmp/script.$$ $commandScript 

    # Test the commands with and w/o options
    test "$(rerun freddy:dance)" = "jumps (3)"
    test "$(rerun freddy:dance --jumps $$)" = "jumps ($$)"
}
