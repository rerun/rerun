#!/usr/bin/env roundup
#

# Let's get started
# -----------------

# Helpers
# ------------


RERUN_MODULE_DIR=$(echo "$RERUN_MODULES" | cut -d: -f1)
MODULE="freddy"
COMMAND="dance"
DESCRIPTION="tell freddy to dance"
OVERWRITE="false"
GENERATE_HELP="true"
STUB="${RERUN_MODULE_DIR}/stubbs/lib/stub/bash"

. "$RERUN_MODULE_DIR/stubbs/lib/functions.sh" add-command-2-test

rerun() {
    command "$RERUN" -M "$RERUN_MODULES" "$@"
}

before() {
    # Create a mockup module
    mkdir -p "$RERUN_MODULE_DIR/$MODULE"
    cat > "$RERUN_MODULE_DIR/$MODULE/metadata" <<EOF
NAME=$MODULE
DESCRIPTION="the $MODULE test module"
OPTIONS=
GENERATE_HELP=true
EOF
}

after() {
    rm -r "${RERUN_MODULE_DIR:?<module-dir?>}/$MODULE"
}

validate() {
    test -d $RERUN_MODULE_DIR/freddy/commands/$COMMAND
    test -f $RERUN_MODULE_DIR/freddy/commands/$COMMAND/metadata
    .  $RERUN_MODULE_DIR/freddy/commands/$COMMAND/metadata
    test -n "$NAME" -a $NAME = $COMMAND
    test -n "$GENERATE_HELP" -a "$GENERATE_HELP" = "true"
    test -n "$DESCRIPTION" -a "$DESCRIPTION" = "tell freddy to dance"
    test -f $RERUN_MODULE_DIR/freddy/commands/$COMMAND/script
    test -f $RERUN_MODULE_DIR/freddy/tests/functions.sh
    test -f $RERUN_MODULE_DIR/freddy/tests/$COMMAND-1-test.sh
    grep '[[ -f ./functions.sh ]] && . ./functions.sh' \
        $RERUN_MODULE_DIR/freddy/tests/$COMMAND-1-test.sh
}


# The Plan
# --------

describe "add-command"

it_generates_command_metadata() {
    mkdir -p "$RERUN_MODULE_DIR/freddy/commands/$COMMAND"


    generate_command_metadata "$COMMAND" "$DESCRIPTION" \
      "${GENERATE_HELP:-true}" "${OVERWRITE:-false}" "$RERUN_MODULE_DIR/freddy/commands/$COMMAND/metadata"    

    test -d "$RERUN_MODULE_DIR/freddy/commands/$COMMAND"
    test -f "$RERUN_MODULE_DIR/freddy/commands/$COMMAND/metadata"
    .  "$RERUN_MODULE_DIR/freddy/commands/$COMMAND/metadata"
    test -n "$NAME" -a "$NAME" = "$COMMAND"

}

it_generates_command_script() {
    mkdir -p "$RERUN_MODULE_DIR/freddy/commands/$COMMAND"
    OUT_SCRIPT="$RERUN_MODULE_DIR/freddy/commands/$COMMAND/script"


    SCRIPT_TEMPLATE=$(rerun_property_get "$STUB" TEMPLATE_COMMAND_SCRIPT)

    generate_command_script "$COMMAND" "$MODULE" \
       "$DESCRIPTION" "$VARIABLES" "$OVERWRITE" "$OUT_SCRIPT" < "$STUB/$SCRIPT_TEMPLATE"
    cat "$OUT_SCRIPT"
    #false
    test -f "$OUT_SCRIPT"
    grep '^#/ command: freddy:dance: "tell freddy to dance"' "$OUT_SCRIPT"
    grep '^#/ usage: rerun freddy:dance \[options\]' "$OUT_SCRIPT"
}

it_generates_option_parser() {
    mkdir -p "$RERUN_MODULE_DIR/$MODULE/commands/$COMMAND"

    PARSER_SCRIPT=$(rerun_property_get "${STUB}" OPTIONS_SCRIPT)

    generate_options_parser "$COMMAND" "$MODULE" "$OVERWRITE" "$STUB" \
        "${RERUN_MODULE_DIR}/$MODULE/commands/${COMMAND}/${PARSER_SCRIPT}"

    test -f "${RERUN_MODULE_DIR}/$MODULE/commands/${COMMAND}/${PARSER_SCRIPT}"
    grep 'rerun_options_parse()' "${RERUN_MODULE_DIR}/$MODULE/commands/${COMMAND}/${PARSER_SCRIPT}"

}

it_generates_unit_test() {
    TEMPLATE=${RERUN_MODULE_DIR}/stubbs/templates/test.functions.sh

    TEST_DIR=$RERUN_MODULE_DIR/freddy/tests
    OUT_TEST=$COMMAND-1-test.sh
    generate_command_test \
        "$COMMAND" "$MODULE" "$OVERWRITE" "$TEST_DIR" "$OUT_TEST" "$TEMPLATE" \
            < "${RERUN_MODULE_DIR}/stubbs/templates/test.roundup" 
    test -f "$TEST_DIR/${OUT_TEST}"
    cat "$TEST_DIR/$OUT_TEST"
    grep '#/ usage:  rerun stubbs:test -m freddy -p dance [--answers <>]' "$TEST_DIR/$OUT_TEST"
}

it_runs_fully_optioned() {
  rerun stubbs:add-command \
    --module "freddy" \
    --command "dance" \
    --description "tell freddy to dance" \
    --overwrite "true" \
    --generate-help "true"

  validate
}
