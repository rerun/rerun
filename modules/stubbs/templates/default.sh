#!/bin/bash
#
# NAME
#
#   @NAME@
#
# DESCRIPTION
#
#   @DESCRIPTION@
#

# Function to print error message and exit
rerun_die() { echo "ERROR: $* " ; exit 1 ; }

# Read module function library
[ -r $RERUN_MODULES/@MODULE@/lib/functions.sh ] && {
  source $RERUN_MODULES/@MODULE@/lib/functions.sh
}
# Parse the command options
[ -r $RERUN_MODULES/@MODULE@/commands/@NAME@/options.sh ] && {
  source $RERUN_MODULES/@MODULE@/commands/@NAME@/options.sh
}

# ------------------------------
# Your implementation goes here.
# ------------------------------

exit $?

# Done