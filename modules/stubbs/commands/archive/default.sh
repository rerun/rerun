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
die() {
    echo "ERROR: $* " ; exit 1;
}

# Parse the command options
[ -r $RERUN_MODULES/stubbs/commands/archive/options.sh ] && {
  . $RERUN_MODULES/stubbs/commands/archive/options.sh
}

export TMPDIR=`mktemp -d /tmp/selfextract.XXXXXX` || die

#
# Create rerun home environment
mkdir -vp $TMPDIR/rerun/modules || die
cp -vr $RERUN_MODULES/$MODULES $TMPDIR/rerun/modules || die
cp -v $RERUN $TMPDIR/rerun || die
# Add launcher script
cp -v $RERUN_MODULES/stubbs/templates/launcher $TMPDIR || die
# Add extract script
cp -v $RERUN_MODULES/stubbs/templates/extract $TMPDIR || die
# Make the archive
cd $TMPDIR
tar cvf payload.tar launcher extract rerun || die

if [ -e "payload.tar" ]; then
    gzip payload.tar || die

    if [ -e "payload.tar.gz" ]; then
	#
	# Prepend the extract script to the payload
        cat extract payload.tar.gz > ${FILE:=rerun.bsx} || die
    else
        die "payload.tar.gz does not exist"
    fi
else
    die "payload.tar does not exist"
fi

echo "${FILE} created"
exit 0

