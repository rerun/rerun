#!/usr/bin/env roundup
#

# Let's get started
# -----------------

# Helpers
# ------------

rerun() {
    command $RERUN -M $RERUN_MODULES "$@"
}

validate() {
    archive=$1
    # Test archive is a plain file
    test -f $archive
    # Test archive is a bash script
    file $archive | grep -q "bash"
    # Test shebang is correct
    test "$(head -1 $archive)" = '#!/usr/bin/env bash'
    # Test there is a version flag
    grep -q "\-version" $archive
    # Test their is a payload
    grep -q "^__ARCHIVE_BELOW__" $archive
    # Test openssl base64 is used
    grep -q "openssl enc \-base64 \-d" $archive
}

# The Plan
# --------

describe "archive"


it_runs_without_options() {
    rerun stubbs:archive     

    validate rerun.bin
    rm rerun.bin
}

it_runs_fully_optioned() {
    rerun stubbs:archive --file /tmp/rerun.bin.$$ --modules stubbs --version 1.0

    validate /tmp/rerun.bin.$$

    # Test the version info exists
    grep -q '^# version: 1.0' /tmp/rerun.bin.$$
    
    rm /tmp/rerun.bin.$$
}

it_builds_the_stubbs_module_rpm() {
    TMPDIR=$(/bin/mktemp -d)
    pushd $TMPDIR
    rerun stubbs:archive --format rpm --modules stubbs
    rpm -qi -p rerun-stubbs-1.0.0-1.noarch.rpm
    popd
    rm -rf $TMPDIR
}

