#!/usr/bin/env roundup
#
# This file contains the test plan for the migrate command.
# Execute the plan by invoking: 
#    
#     rerun stubbs:test -m stubbs -p migrate
#

# Helpers
# ------------

rerun() {
    command $RERUN -M $RERUN_MODULES "$@"
}

# The Plan
# --------

describe "migrate"

it_runs_without_arguments() {
    rerun stubbs:migrate
}
