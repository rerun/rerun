#!/usr/bin/env roundup
#

# Let's get started
# -----------------

# Helpers
# ------------
first_rerun_module_dir=$(echo "$RERUN_MODULES" | cut -d: -f1)

. $first_rerun_module_dir/stubbs/lib/functions.sh functional-bash-2-test || exit 1

rerun() {
    command $RERUN -M $RERUN_MODULES "$@"
}

test_module_name="my-test-module"
test_command_name="my-test-command"

before() {
  # create a module and command
  
  rerun stubbs: add-module \
    --module "$test_module_name" \
    --description "my test module"

  rerun stubbs: add-command \
    --module "$test_module_name" \
    --command "$test_command_name" \
    --description "my test command"
  
  rerun stubbs: add-option \
    --module "$test_module_name" \
    --command "$test_command_name" \
    --option "recognized1" \
    --description "my recognized option 1" \
    --arg "true" \
    --required "true"

  rerun stubbs: add-option \
    --module "$test_module_name" \
    --command "$test_command_name" \
    --option "recognized2" \
    --description "my recognized option 2" \
    --arg "true" \
    --required "true"
}

after() {
    # clean up the module
    rm -r $first_rerun_module_dir/$test_module_name
}


# The Plan
# --------

describe "functional: argument passthrough"

# $ rerun module:command --recognized1 val --recognized2 val
it_runs_with_required_options() {
  rerun "${test_module_name}:" "${test_command_name}" \
    --recognized1 "val" \
    --recognized2 "val"
}

# $ rerun module:command --recognized1 val --unrecognized1 val --recognized2 val --unrecognized2 val
it_runs_with_2recog_2unrecog_with_vals() {
  rerun "${test_module_name}:" "${test_command_name}" \
    --recognized1 "val" \
    --unrecognized1 "val" \
    --recognized2 "val" \
    --unrecognized2 "val"
}

# $ rerun module:command --recognized1 val --unrecognized1 --recognized2 val --unrecognized2 val
it_runs_with_2recog_2unrecog_some_vals() {
  rerun "${test_module_name}:" "${test_command_name}" \
    --recognized1 "val" \
    --unrecognized1 \
    --recognized2 "val" \
    --unrecognized2 "val"
}

# $ rerun module:command --recognized1 val --unrecognized1 --unrecognized2 val --recognized2 val --unrecognized3
it_runs_with_2recog_3unrecog_some_vals() {
  rerun "${test_module_name}:" "${test_command_name}" \
    --recognized1 "val" \
    --unrecognized1 \
    --recognized2 "val" \
    --unrecognized2 "val" \
    --unrecognized3
}

# $ rerun module:command --recognized1 --unrecognized1 val --unrecognized2 val
it_fails_with_1recog_2unrecog_missing_required() {
  rerun "${test_module_name}:" "${test_command_name}" \
    --recognized1 "val" \
    --unrecognized1 "val" \
    --unrecognized2 "val" 2>&1 | grep 'missing required option: --recognized2'
}

# $ rerun module:command --recognized1 --unrecognized1 val --unrecognized2 val --recognized2
it_fails_with_2recog_2unrecog_missing_val() {
  rerun "${test_module_name}:" "${test_command_name}" \
    --recognized1 "val" \
    --unrecognized1 "val" \
    --unrecognized2 "val" \
    --recognized2 2>&1 | grep 'SYNTAX: option requires argument: --recognized2'
}
