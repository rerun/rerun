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
die() { echo "ERROR: $* " ; exit 1 ; }

# Parse the command options
[ -r $RERUN_MODULES/@MODULE@/commands/@NAME@/options.sh ] && {
  . $RERUN_MODULES/@MODULE@/commands/@NAME@/options.sh
}

# ------------------------------
# Your implementation goes here.
# ------------------------------

exit $?

