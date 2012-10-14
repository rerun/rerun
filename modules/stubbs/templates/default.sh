#!/usr/bin/env bash
#
#/ command: @MODULE@:@NAME@: "@DESCRIPTION@"
#
#/ usage: rerun @MODULE@:@NAME@ [options]
#
#/ variables: @VARIABLES@

# Read module function library.
. $RERUN_MODULES/@MODULE@/lib/functions.sh || { 
  echo >&2 "Failed loading function library" ; exit 1 ; 
}

# Parse the command options.
[ -r $RERUN_MODULE_DIR/commands/@NAME@/options.sh ] && {
  . $RERUN_MODULE_DIR/commands/@NAME@/options.sh || exit 2 ;
}

# Exit immediately upon non-zero exit. See [set](http://ss64.com/bash/set.html)
set -e

# ------------------------------
# Your implementation goes here.
# ------------------------------

exit $?

# Done
