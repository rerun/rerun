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

# Source common function library
source $RERUN_MODULES/stubbs/lib/functions.sh || { echo "failed laoding function library" ; exit 1 ; }

# Parse the command options
[ -r $RERUN_MODULES/stubbs/commands/archive/options.sh ] && {
  . $RERUN_MODULES/stubbs/commands/archive/options.sh
}

CWD=$(pwd); #remember current working directory
[ -n "${LIST}"  ] && VERBOSE=v 
[ -z "${FILE}"  ] && FILE=$CWD/rerun.bin

# create a work directory the archive content
export PAYLOAD=`mktemp -d /tmp/rerun.bin.XXXXXX` || rerun_die

#
# Start adding payload content

# Copy in the specified modules
mkdir -p $PAYLOAD/rerun/modules || rerun_die
for module in $MODULES
do
    cp -r $RERUN_MODULES/$module $PAYLOAD/rerun/modules || rerun_die
done

# Copy rerun itself
cp $RERUN $PAYLOAD/rerun || rerun_die

# Copy in the extract and launcher scripts used during execution
for template in $RERUN_MODULES/stubbs/templates/{extract,launcher}
do
    # replace the template substitution tokens ...
    sed -e "s/@GENERATOR@/stubbs#archive/" \
	-e "s/@DATE@/$(date)/" \
	-e "s/@USER@/$USER/" \
	$template > $PAYLOAD/$(basename $template) || rerun_die
    # ... and save it to the payload --^
done

#
# Archive the content
#

# make the payload.tar file
cd $PAYLOAD
tar c${VERBOSE}f payload.tar launcher extract rerun || rerun_die

# compress the tar
if [ -e "payload.tar" ]; then
    gzip payload.tar || rerun_die

    if [ -e "payload.tar.gz" ]; then
	#
	# Prepend the extract script to the payload.
	#    and thus turn the thing into a shell script!
	#
        cat extract payload.tar.gz > ${FILE} || rerun_die
    else
        rerun_die "payload.tar.gz does not exist"
    fi
else
    rerun_die "payload.tar does not exist"
fi

echo "Wrote self extracting archive script: ${FILE}"
exit 0

# Done

