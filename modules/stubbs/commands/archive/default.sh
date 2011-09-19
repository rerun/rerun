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
[ -n "${LIST}"  ] && VERB=v 
[ -z "${FILE}"  ] && FILE=$CWD/rerun.bin

# create a work directory the archive content
export PAYLOAD=`mktemp -d /tmp/rerun.bin.XXXXXX` || die

#
# Start adding payload content

# Copy in the specified modules
mkdir -p $PAYLOAD/rerun/modules || die
for module in $MODULES
do
    cp -r $RERUN_MODULES/$module $PAYLOAD/rerun/modules || die
done

# Copy rerun itself
cp $RERUN $PAYLOAD/rerun || die

# Copy in the extract and launcher scripts used during execution
for template in $RERUN_MODULES/stubbs/templates/{extract,launcher}
do
    # replace the template substitution tokens ...
    sed -e "s/@GENERATOR@/stubbs#archive/" \
	-e "s/@DATE@/$(date)/" \
	-e "s/@USER@/$USER/" \
	$template > $PAYLOAD/$(basename $template) || die
    # ... and save it to the payload --^
done

#
# Archive the content
#

# make the payload.tar file
cd $PAYLOAD
tar c${VERB}f payload.tar launcher extract rerun || die

# compress the tar
if [ -e "payload.tar" ]; then
    gzip payload.tar || die

    if [ -e "payload.tar.gz" ]; then
	#
	# Prepend the extract script to the payload.
	#    and thus turn the thing into a shell script!
	#
        cat extract payload.tar.gz > ${FILE} || die
    else
        die "payload.tar.gz does not exist"
    fi
else
    die "payload.tar does not exist"
fi

echo "Wrote self extracting archive script: ${FILE}"
exit 0

# Done

