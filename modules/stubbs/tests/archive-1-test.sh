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
    file $archive | grep "bash"
    # Test shebang is correct
    test "$(head -1 $archive)" = '#!/usr/bin/env bash'
    # Test there is a version flag
    grep "\-version" $archive
    # Check for decoder comment.
    grep '^# decoder:' $archive
    # Test their is a payload
    grep "^__ARCHIVE_BELOW__" $archive

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
    grep '^# archive-version: 1.0' /tmp/rerun.bin.$$
    
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
        MYDIST="$(rpm --eval %{?dist})";
    else
        if [[ "$(uname -s)" = "Darwin" && -x /opt/local/bin/rpmbuild ]]
        then
            MYDIST=".osx"; # ok run the test, macports rpm installed
        else
            return 0; # bail out of the test.
        fi
    fi
    TMPDIR=$(mktemp -d "/tmp/rerun.test.XXXX")
    pushd $TMPDIR
    rerun stubbs:archive --format rpm --modules stubbs --release 1
    rpm -qi -p rerun-stubbs-$(grep ^VERSION=  $RERUN_MODULES/stubbs/metadata | cut -d= -f2)-1${MYDIST}.noarch.rpm
    popd
    rm -rf ${TMPDIR}
}

it_extracts_only_and_exits() {
    rerun stubbs:add-module --module freddy --description "none"
    rerun stubbs:add-command --module freddy --command says --description "none"
    rerun stubbs:add-option --module freddy --command says --option msg \
        --description none --required true --export false --default nothing
    rerun stubbs:archive --file /tmp/rerun.bin.$$ --modules freddy --version 1.0

    /tmp/rerun.bin.$$ --extract-only /tmp/myextract.$$
    test -d /tmp/myextract.$$
    test -f /tmp/myextract.$$/launcher
    test -d /tmp/myextract.$$/rerun
    test -x /tmp/myextract.$$/rerun/rerun
    test -d /tmp/myextract.$$/rerun/modules
    test -d /tmp/myextract.$$/rerun/modules/freddy

    rm -r /tmp/myextract.$$
    rm /tmp/rerun.bin.$$
}


it_runs_from_specified_extract_dir() {
    rerun stubbs:add-module --module freddy --description "none"
    rerun stubbs:add-command --module freddy --command says --description "none"
    rerun stubbs:add-option --module freddy --command says --option msg \
        --description none --required true --export false --default nothing
    cat $RERUN_MODULES/freddy/commands/says/script |
    sed 's/# Put the command implementation here./echo "msg ($MSG)"/g' > /tmp/script.$$
    mv /tmp/script.$$ $RERUN_MODULES/freddy/commands/says/script

    rerun stubbs:archive --file /tmp/rerun.bin.$$ --modules freddy --version 1.0

    OUT=$(/tmp/rerun.bin.$$ --extract-dir /tmp/myextract.$$ freddy)
    echo $OUT | grep "says: \"none\""
    OUT=$(/tmp/rerun.bin.$$ --extract-dir /tmp/myextract.$$ freddy:says --msg hi)
    test "$OUT" = "msg (hi)"
    rm /tmp/rerun.bin.$$
}

it_runs_archive_from_overridden_TMPDIR() {
    export TMPDIR=/tmp/stubbs.archive.$$
    mkdir -p $TMPDIR

    rerun stubbs:add-module --module freddy --description "none"
    rerun stubbs:add-command --module freddy --command print_tmpdir --description "none"

    cat $RERUN_MODULES/freddy/commands/print_tmpdir/script |
    sed 's,# Put the command implementation here.,echo "$TMPDIR",g' > /tmp/script.$$
    mv /tmp/script.$$ $RERUN_MODULES/freddy/commands/print_tmpdir/script

    rerun stubbs:archive --file /tmp/rerun.bin.$$ --modules freddy --version 1.0

    OUT=$(/tmp/rerun.bin.$$ freddy:print_tmpdir)
    test "$OUT" = "$TMPDIR"
    test -d $TMPDIR
    rm -rf /tmp/rerun.bin.$$ /tmp/stubbs.archive.$$
}

it_errors_with_missing_extract_dir_arg(){
    rerun stubbs:add-module --module freddy --description "none"
    rerun stubbs:add-command --module freddy --command print_tmpdir --description "none"
    cat $RERUN_MODULES/freddy/commands/print_tmpdir/script |
    sed 's,# Put the command implementation here.,echo "$TMPDIR",g' > /tmp/script.$$
    mv /tmp/script.$$ $RERUN_MODULES/freddy/commands/print_tmpdir/script

    rerun stubbs:archive --file /tmp/rerun.bin.$$ --modules freddy --version 1.0
    ERR=$(mktemp /tmp/rerun.archive.err.$$)
    ! /tmp/rerun.bin.$$ --extract-only 2> $ERR
    usage="usage: rerun.bin.$$ [--extract-only|-N <>] [--extract-dir|-D <>] [args]"
    test "${usage}" = "$(cat $ERR)"
    rm -rf /tmp/rerun.bin.$$ /tmp/stubbs.archive.$$ $ERR
}

