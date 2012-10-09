#!/usr/bin/env bash
#
# NAME
#
#   archive
#
# DESCRIPTION
#
#   Build a self extracting archive
#
#/ usage: stubbs:archive [ --file|-f <>] --modules <*> [ --version|-v <>]

# Source common function library
source $RERUN_MODULE_DIR/lib/functions.sh || { echo "failed laoding function library" ; exit 1 ; }

# Parse the command options
[ -r $RERUN_MODULE_DIR/commands/archive/options.sh ] && {
  . $RERUN_MODULE_DIR/commands/archive/options.sh
}

CWD=$(pwd); #remember current working directory.

# Check if file option was specified and if not set it to rerun.bin.
[ -z "${FILE}"  ] && FILE=rerun.bin 

# Prepend curren working directory if relative file path.
[[ ${FILE} == "/"* ]] || FILE=$CWD/$FILE

[ ! -d $(dirname ${FILE}) ] && rerun_option_error "directory not found: $(dirname ${FILE})"

# Default version to blank if unspecified.
[ -z "${VERSION}" ] && VERSION=

# create a work directory the archive content
export PAYLOAD=`mktemp -d /tmp/rerun.stubbs:archive.XXXXXX` || rerun_die

#
# Start preparing the payload content.
#

# Iterate through the the specified modules and add them to payload
mkdir -p $PAYLOAD/rerun/modules || rerun_die
pushd $RERUN_MODULES >/dev/null || rerun_die
for module in $MODULES
do
    # Check for a commands subdir to be sure it looks like a module
    if [ -d $RERUN_MODULES/$module/commands ]
    then
	cp -r $RERUN_MODULES/$module $PAYLOAD/rerun/modules || rerun_die
    fi
done
popd >/dev/null

# Copy rerun itself to the payload
cp $RERUN $PAYLOAD/rerun || rerun_die

# Copy in the extract and launcher scripts used during execution
for template in $RERUN_MODULE_DIR/templates/{extract,launcher}
do
    # replace the template substitution tokens ...
    sed -e "s/@GENERATOR@/stubbs:archive/" \
	-e "s/@DATE@/$(date)/" \
	-e "s/@USER@/$USER/" \
	-e "s/@VERSION@/$VERSION/" \
	$template > $PAYLOAD/$(basename $template) || rerun_die
    # ... and save it to the payload --^
done

#
# Archive the content
#

cd $PAYLOAD

# make the payload.tar file
tar cf payload.tar launcher extract rerun || rerun_die

# compress and base64 encode the tar file
if [ -e "payload.tar" ]; then
    gzip -c payload.tar | openssl enc -base64 > payload.tgz.base64   || rerun_die

    if [ -e "payload.tgz.base64" ]; then
	#
	# Prepend the extract script to the payload.
	#    and thus turn the thing into a shell script!
	#
        cat extract payload.tgz.base64 > ${FILE} || rerun_die
    else
        rerun_die "$PAYLOAD/payload.tgz.base64 does not exist"
    fi
else
    rerun_die "payload.tar does not exist"
fi

#
# Make the archive executable
#
chmod +x ${FILE} || rerun_die "failed setting archive executable"
#
# Clean up the temp directory
#
rm -rf $PAYLOAD


echo "Wrote self extracting archive script: ${FILE}"
exit 0

# Done

