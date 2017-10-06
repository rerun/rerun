#!/usr/bin/env roundup
#

# Let's get started
# -----------------

# Helpers
# ------------
. $RERUN || exit 1

rerun() {
    command $RERUN -M $RERUN_MODULES "$@"
}

# Mock a module and command
before() {
    first_rerun_module_dir=$(echo "$RERUN_MODULES" | cut -d: -f1)

    mkdir -p $first_rerun_module_dir/freddy
    cat > $first_rerun_module_dir/freddy/metadata <<EOF
NAME=freddy
EOF
    mkdir -p $first_rerun_module_dir/freddy/commands
    mkdir -p $first_rerun_module_dir/freddy/commands/dance
    cat > $first_rerun_module_dir/freddy/commands/dance/metadata <<EOF
NAME=dance
OPTIONS=
EOF
    cat > $first_rerun_module_dir/freddy/commands/dance/script <<EOF
#!/usr/bin/env bash
#/ usage:
#/ rerun-variables:
#/ option-variables:
EOF
}



after() {
    first_rerun_module_dir=$(echo "$RERUN_MODULES" | cut -d: -f1)

    # clean up the mock module
    if test -d $first_rerun_module_dir/freddy
    then rm -r $first_rerun_module_dir/freddy
    fi
}

validate() {
    first_rerun_module_dir=$(echo "$RERUN_MODULES" | cut -d: -f1)

    #
    # Check for the option metadata 
    test -f $first_rerun_module_dir/freddy/options/jumps/metadata
    .  $first_rerun_module_dir/freddy/options/jumps/metadata
    test -n "$NAME" -a $NAME = jumps 
    test -n "$DESCRIPTION" -a "$DESCRIPTION" = "jump #num times"
    # Check the option parser
    test -f $first_rerun_module_dir/freddy/commands/dance/options.sh
    grep '\--jumps) rerun_option_check $# $1;' $first_rerun_module_dir/freddy/commands/dance/options.sh ||
      grep '\--jumps|-j) rerun_option_check $# $1;' $first_rerun_module_dir/freddy/commands/dance/options.sh
    grep '[ -z "$JUMPS" ]' $first_rerun_module_dir/freddy/commands/dance/options.sh
    grep '"missing required option: --jumps"' $first_rerun_module_dir/freddy/commands/dance/options.sh
    grep '^#/ usage: '  $first_rerun_module_dir/freddy/commands/dance/options.sh
    grep '^#/ option-variables:' $first_rerun_module_dir/freddy/commands/dance/script

    return $?
}

# The Plan
# --------

describe "add-option"

it_runs_fully_optioned() {
  # --jumps|-j <3>
  rerun stubbs:add-option \
    --module "freddy" \
    --command "dance" \
    --option "jumps" \
    --description "jump #num times" \
    --required "true" \
    --export "true" \
    --default 3 \
    --short "j" \
    --long "jumps" \
    --arg "true"

  validate
  first_rerun_module_dir=$(echo "$RERUN_MODULES" | cut -d: -f1)

  # Check the command's option assignment
  OPTIONS=( $(.  $first_rerun_module_dir/freddy/commands/dance/metadata; echo $OPTIONS) )
  test -n "$OPTIONS"
  rerun_list_contains "jumps" "${OPTIONS[*]}"
}

it_exports_option_variable() {
    # --jumps|-j <3>
    rerun stubbs:add-option --module freddy --command dance \
        --option jumps --description "jump #num times" --required true \
        --default 3 --export true
    # --height|-h <3>
    rerun stubbs:add-option --module freddy --command dance \
        --option height --description "jump #height" --required false \
        --default 3 --export false
    validate
    first_rerun_module_dir=$(echo "$RERUN_MODULES" | cut -d: -f1)

    # Check the command's option assignment
    OPTIONS=( $(.  $first_rerun_module_dir/freddy/commands/dance/metadata; echo $OPTIONS) )
    test -n "$OPTIONS"
    test ${#OPTIONS[*]} = 2
    rerun_list_contains "jumps" "${OPTIONS[@]}"
    rerun_list_contains "height" "${OPTIONS[@]}"
    # Check the option metadata
    grep "EXPORT=true"  $first_rerun_module_dir/freddy/options/jumps/metadata
    # Check the option parser
    grep 'export JUMPS$' $first_rerun_module_dir/freddy/commands/dance/options.sh
    grep -v 'export HEIGHT$' $first_rerun_module_dir/freddy/commands/dance/options.sh
}

it_does_not_add_duplicate_assignments() {
    # --jumps|-j <3>
    rerun stubbs:add-option --module freddy --command dance \
        --option jumps --description "jump #num times" \
        --required true --export true --default 3
    # Check the command's option assignment
    first_rerun_module_dir=$(echo "$RERUN_MODULES" | cut -d: -f1)

    OPTIONS=( $(.  $first_rerun_module_dir/freddy/commands/dance/metadata; echo $OPTIONS) )
    test "${#OPTIONS[*]}" = 1
    rerun_list_contains "jumps" "${OPTIONS[*]}"

    # Add the option again and be sure the assignment doesn't get duplicated.
    rerun stubbs:add-option --module freddy --command dance \
        --option jumps --description "jump #num times" \
        --required true --export true --default 3
    OPTIONS=( $(.  $first_rerun_module_dir/freddy/commands/dance/metadata; echo $OPTIONS) )
    test "${#OPTIONS[*]}" = 1
    rerun_list_contains "jumps" "${OPTIONS[*]}"

}

it_should_not_overquote_descriptions() {
   # --jumps|-j <3>
    rerun stubbs:add-option --module freddy --command dance \
        --option jumps --description "jump #num times" \
        --required true --export true --default 3
    # repeat the declaration
    rerun stubbs:add-option --module freddy --command dance \
        --option jumps --description "jump #num times" \
        --required true --export true --default 3
    # Check the description
    first_rerun_module_dir=$(echo "$RERUN_MODULES" | cut -d: -f1)

    DESC=$(awk -F= '/DESCRIPTION=.*/ {print $2}' \
        $first_rerun_module_dir/freddy/options/jumps/metadata)
    test "$DESC" = '"jump #num times"'
}

it_fails_when_option_name_contains_whitespace() {

    rerun stubbs:add-option --module freddy --command dance \
        --option "jumps and skips" --description "bogus" --required true \
        --default "bogus" --export true  2>&1 | grep "ERROR: option name cannot contain whitespace"
}

it_quotes_defaults_with_whitespace() {
    # --jumps <skiddly doo dap dee>
    rerun stubbs:add-option --module freddy --command dance \
        --option jumps --description "jump #num times" --required true \
        --default "skiddly doo dap dee" --export true

    validate
    # Check the command's option assignment
    first_rerun_module_dir=$(echo "$RERUN_MODULES" | cut -d: -f1)

    OPTIONS=( $(.  $first_rerun_module_dir/freddy/commands/dance/metadata; echo $OPTIONS) )
    test -n "$OPTIONS"
    test ${#OPTIONS[*]} = 1
    rerun_list_contains "jumps" "${OPTIONS[@]}"

    # Check the option metadata
    grep 'DEFAULT="skiddly doo dap dee"'  $first_rerun_module_dir/freddy/options/jumps/metadata

}
