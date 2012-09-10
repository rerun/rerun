#!/usr/bin/env roundup
#
# This file contains test scripts to run for the @COMMAND@ command.
# Execute it by invoking: 
#    
#     rerun stubbs:test -m @MODULE@ -c @COMMAND@
#

# Helpers
# ------------

rerun() {
    command $RERUN -M $RERUN_MODULES "$@"
}

# The Plan
# --------

describe "@MODULE@:@COMMAND@"

it_runs_without_arguments() {
    rerun @MODULE@:@COMMAND@
}