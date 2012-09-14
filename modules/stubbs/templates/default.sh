#!/usr/bin/env bash
#
#/ command: @MODULE@:@NAME@: "@DESCRIPTION@"
#
#/ usage: rerun @MODULE@:@NAME@ [options]
#
#/ variables: @VARIABLES@

# Read module function library.
source $RERUN_MODULES/@MODULE@/lib/functions.sh || { 
  echo "Failed loading function library" >&2 ; exit 1 ; 
}

# Parse the command options.
[ -r $RERUN_MODULES/@MODULE@/commands/@NAME@/options.sh ] && {
  source $RERUN_MODULES/@MODULE@/commands/@NAME@/options.sh || exit 2 ;
}

# Exit immediately upon non-zero exit. See [set](http://ss64.com/bash/set.html)
set -e

# ------------------------------
# Your implementation goes here.
# ------------------------------

exit $?

# Done
