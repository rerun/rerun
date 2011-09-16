#!/bin/bash
#
# NAME
#
#   archive
#
# DESCRIPTION
#
#   Build a self extracting archive
#

# Function to print error message and exit
die() { echo "ERROR: $* " ; exit 1 ; }

# Parse the command options
[ -r $RERUN_MODULES/stubbs/commands/archive/options.sh ] && {
  . $RERUN_MODULES/stubbs/commands/archive/options.sh
}

CWD=$(pwd); #remember current working directory
[ -n "${LIST}" ] && VERB=v 
[ -z "${FILE}"  ] && FILE=$CWD/rerun.bsx

export TMPDIR=`mktemp -d /tmp/rerun.bsx.XXXXXX` || die

#
# Create rerun home environment
mkdir -p $TMPDIR/rerun/modules || die
cp -r $RERUN_MODULES/$MODULES $TMPDIR/rerun/modules || die
cp $RERUN $TMPDIR/rerun || die
for template in $RERUN_MODULES/stubbs/templates/{extract,launcher}
do
    # substitute tokens
    sed -e "s/@GENERATOR@/stubbs#archive/" \
	-e "s/@DATE@/$(date)/" \
	-e "s/@USER@/$USER/" \
	$template > $TMPDIR/$(basename $template) || die
done

# Make the archive
cd $TMPDIR
tar c${VERB}f payload.tar launcher extract rerun || die

if [ -e "payload.tar" ]; then
    gzip payload.tar || die

    if [ -e "payload.tar.gz" ]; then
	#
	# Prepend the extract script to the payload
        cat extract payload.tar.gz > ${FILE} || die
    else
        die "payload.tar.gz does not exist"
    fi
else
    die "payload.tar does not exist"
fi

echo "Wrote self extracting script: ${FILE}"
exit 0

