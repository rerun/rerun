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
        --meta-module bash
    
    # Create command: freddy:dance
    rerun stubbs:add-command --module "freddy" \
        --command dance --description "tell freddy to dance"

    command_script=$RERUN_MODULES/freddy/commands/dance/script
    # Be sure the command script has execute bit set 
    test -x $command_script
    
    # Create option: freddy:dance --jumps <3>
    rerun stubbs:add-option --module freddy --command dance \
        --option jumps --description "jump #num times" \
        --required true --export false --default 3    

    test -x $command_script 
 
    # ... Rewrite the handler to echo option value
    sed 's/\# Put the command implementation here./echo "jumps ($JUMPS)"/' \
        $command_script > /tmp/script.$$
    mv /tmp/script.$$ $command_script 

    # Test the commands with and w/o options
    test "$(rerun freddy:dance)" = "jumps (3)"
    test "$(rerun freddy:dance --jumps $$)" = "jumps ($$)"
}
