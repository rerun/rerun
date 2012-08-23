#!/usr/bin/env bash
#
# NAME
#
#   extract
#
# DESCRIPTION
#
#   extracts the rerun module from the self extracting archive
#

# Parse the command options
[ -r $RERUN_MODULES/stubbs/commands/extract/options.sh ] && {
  source $RERUN_MODULES/stubbs/commands/extract/options.sh
}

# Read module function library
[ -r $RERUN_MODULES/stubbs/lib/functions.sh ] && {
  source $RERUN_MODULES/stubbs/lib/functions.sh
}

# ------------------------------
# Your implementation goes here.
# ------------------------------

if [ -z "${RERUN}" ]
then
   echo "RERUN environment not defined" 1>&2
   exit 1
fi

if [ ! -x "${RERUN}" ]
then
   echo "RERUN script ${RERUN} does not exist or is not executable" 1>&2
   exit 1
fi

if [ -z "${RERUN_MODULES}" ]
then
   echo "RERUN_MODULES environment not defined" 1>&2
   exit 1
fi

if [ ! -d "${RERUN_MODULES}" ]
then
   echo "RERUN_MODULES ${RERUN_MODULES} directory does not exist" 1>&2
   exit 1
fi

echo "DEBUG:"
echo "DEBUG: oldCWD: ${oldCWD}"
cwd=$(pwd)
pushd "${RERUN_MODULES}/.."
   tar cf - modules rerun | (cd ${oldCWD} && tar xf -)
popd
echo "END DEBUG:"

exit $?

# Done
