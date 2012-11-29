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
    grep -q '^# archive-version: 1.0' /tmp/rerun.bin.$$
    
    rm /tmp/rerun.bin.$$
}

it_handles_comands_using_quoted_arguments() {
    rerun stubbs:add-module --module freddy --description "none"
    rerun stubbs:add-command --module freddy --command says --description "none"
    rerun stubbs:add-option --module freddy --command says --option msg \
        --description none --required true --export false --default nothing
    cat $RERUN_MODULES/freddy/commands/says/script |
    sed 's/# Put the command implementation here./echo "msg ($MSG)"/g' > /tmp/script.$$
    mv /tmp/script.$$ $RERUN_MODULES/freddy/commands/says/script

    rerun stubbs:archive --file /tmp/rerun.bin.$$ --modules freddy --version 1.0

    output=$(/tmp/rerun.bin.$$ freddy:says --msg "whats happening")
    test "$output" = "msg (whats happening)"
    
    rm /tmp/rerun.bin.$$
    rm -r $RERUN_MODULES/freddy
}

it_builds_the_stubbs_module_rpm() {
    if [[ "$(uname -s)" = "Linux" && -x /usr/bin/rpmbuild ]]
    then
        :; # ok run the test
    else
        return 0; # bail out of the test.
    fi
    TMPDIR=$(mktemp -d "/tmp/rerun.test.XXXX")
    pushd $TMPDIR
    rerun stubbs:archive --format rpm --modules stubbs --release 1
    rpm -qi -p rerun-stubbs-$(grep ^VERSION=  $RERUN_MODULES/stubbs/metadata | cut -d= -f2)-1.noarch.rpm
    popd
    rm -rf $TMPDIR
}

