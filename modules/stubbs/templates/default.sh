#!/usr/bin/env bash
#
# NAME
#
#   @NAME@
#
# DESCRIPTION
#
#   @DESCRIPTION@
#

# Parse the command options
[ -r $RERUN_MODULES/@MODULE@/commands/@NAME@/options.sh ] && {
  source $RERUN_MODULES/@MODULE@/commands/@NAME@/options.sh
}

# Read module function library
[ -r $RERUN_MODULES/@MODULE@/lib/functions.sh ] && {
  source $RERUN_MODULES/@MODULE@/lib/functions.sh
}

# ------------------------------
# Your implementation goes here.
# ------------------------------

exit $?

# Done
