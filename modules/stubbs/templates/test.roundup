#!/usr/bin/env roundup
#
# This file contains the test plan for the @COMMAND@ command.
# Execute the plan by invoking: 
#    
#     rerun stubbs:test -m @MODULE@ -p @COMMAND@
#

# Helpers
# ------------

rerun() {
    command $RERUN -M $RERUN_MODULES "$@"
}

# The Plan
# --------

describe "@COMMAND@"

it_runs_without_arguments() {
    rerun @MODULE@:@COMMAND@
}
