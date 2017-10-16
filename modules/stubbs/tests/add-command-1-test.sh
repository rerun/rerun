#!/usr/bin/env roundup
#

# Let's get started
# -----------------

# Helpers
# ------------

rerun() {
    command $RERUN -M $RERUN_MODULES "$@"
}

before() {
    first_rerun_module_dir=$(echo "$RERUN_MODULES" | cut -d: -f1)
    mkdir -p $first_rerun_module_dir/freddy
    cat > $first_rerun_module_dir/freddy/metadata <<EOF
NAME=freddy
DESCRIPTION=
OPTIONS=
GENERATE_HELP=true
EOF
}

after() {
    first_rerun_module_dir=$(echo "$RERUN_MODULES" | cut -d: -f1)
    rm -r $first_rerun_module_dir/freddy
}

validate() {
    first_rerun_module_dir=$(echo "$RERUN_MODULES" | cut -d: -f1)
    test -d $first_rerun_module_dir/freddy/commands/dance
    test -f $first_rerun_module_dir/freddy/commands/dance/metadata
    .  $first_rerun_module_dir/freddy/commands/dance/metadata
    test -n "$NAME" -a $NAME = dance
    test -n "$GENERATE_HELP" -a "$GENERATE_HELP" = "true"
    test -n "$DESCRIPTION" -a "$DESCRIPTION" = "tell freddy to dance"
    test -f $first_rerun_module_dir/freddy/commands/dance/script
    test -f $first_rerun_module_dir/freddy/tests/functions.sh
    test -f $first_rerun_module_dir/freddy/tests/dance-1-test.sh
    grep '[[ -f ./functions.sh ]] && . ./functions.sh' \
        $first_rerun_module_dir/freddy/tests/dance-1-test.sh
}


# The Plan
# --------

describe "add-command"

it_runs_fully_optioned() {
  rerun stubbs:add-command \
    --module "freddy" \
    --command "dance" \
    --description "tell freddy to dance" \
    --overwrite "true" \
    --generate-help "true"

  validate
}
