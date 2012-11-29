#!/usr/bin/env roundup
#

# Let's get started
# -----------------

# Helpers
# ------------

rerun() {
    command $RERUN -M $RERUN_MODULES "$@"
}

validate_manpage() {
    doc=$1
    test -f $doc

    file $doc | grep -q roff
    grep -q '.TH stubbs 1' $doc
    grep -q '.SH NAME' $doc
    grep -q '.SH SYNOPSIS' $doc
    grep -q '.SH COMMANDS' $doc

}

validate_webpages() {
    dir=$1
    test -f $dir/index.html
    test -f $dir/docs.css
    test -d $dir/lib
    test -d $dir/options
    test -d $dir/commands
    for cmd in $dir/commands/*
    do
        cmd_name=$(basename $cmd)
        test -f $dir/commands/$cmd_name/index.html
        test -f $dir/commands/$cmd_name/script.html
    done
    for opt in $dir/options/*
    do
        opt_name=$(basename $opt)
        test -f $dir/options/$opt_name/index.html
    done

}

# The Plan
# --------

describe "docs"


it_runs_interactively() {
    rerun stubbs:docs <<EOF
stubbs
EOF
    validate_manpage $RERUN_MODULE_DIR/docs/stubbs.1
    validate_webpages $RERUN_MODULE_DIR/docs
}

it_runs_fully_optioned() {
    DIR=$(mktemp -d /tmp/stubbs.docs.XXXX)
    rerun stubbs:docs --module "stubbs" --dir "$DIR"
    
    validate_manpage "$DIR/stubbs.1"
    validate_webpages $DIR

    rm -r "$DIR"
}

