#!/usr/bin/env roundup
#

# Let's get started
# -----------------

# Helpers
# ------------
. "$RERUN_MODULE_DIR/lib/functions.sh" add-module-1-test

rerun() {
    command "$RERUN" -M "$RERUN_MODULES" "$@"
}

validate() {
    first_rerun_module_dir=$(echo "$RERUN_MODULES" | cut -d: -f1)
    test -f "$first_rerun_module_dir/freddy/metadata"
    . "$first_rerun_module_dir/freddy/metadata"
    test -n "$NAME" -a "$NAME" = freddy 
    test -n "$DESCRIPTION" -a "$DESCRIPTION" = "A dancer in a red beret and matching suspenders"
    test -n "$SHELL" -a "$SHELL" = "bash"
    test "$VERSION" = "1.0.0"
    grep '^REQUIRES=' "$first_rerun_module_dir/freddy/metadata"
    grep '^EXTERNALS=' "$first_rerun_module_dir/freddy/metadata"

}

# The Plan
# --------

describe "add-module"

it_generates_module_structure() {
  local -r RERUN_MODULE_HOME_DIR=$(mktemp -d "fun.XXXX")
  generate_module_structure "$RERUN_MODULE_HOME_DIR"
  test -d "$RERUN_MODULE_HOME_DIR/commands"
  test -d "$RERUN_MODULE_HOME_DIR/lib"
}

it_generates_modue_metadata() {
  local -r RERUN_MODULE_HOME_DIR=$(mktemp -d "fun.XXXX")  
  generate_module_metadata "$RERUN_MODULE_HOME_DIR" "new-module" "this is a new module"
  test -f "$RERUN_MODULE_HOME_DIR/metadata"
  . "$RERUN_MODULE_HOME_DIR/metadata"
  test "$NAME" = "new-module" 
  test "$DESCRIPTION" = "this is a new module"
}



it_runs_fully_optioned() {
  rerun stubbs:add-module \
    --module "freddy" \
    --description "A dancer in a red beret and matching suspenders" \
    --template ""

  validate
}

it_should_add_module_from_template() {

   rerun stubbs:add-module --module "freddy" \
        --description "A dancer in a red beret and matching suspenders" \

   # Create freddy:dance
   first_rerun_module_dir=$(echo "$RERUN_MODULES" | cut -d: -f1)

   mkdir -p "$first_rerun_module_dir/freddy/commands/dance"
   cat > "$first_rerun_module_dir/freddy/commands/dance/metadata" <<EOF
NAME=dance
OPTIONS=
EOF
   cat > "$first_rerun_module_dir/freddy/commands/dance/script" <<EOF
#!/bin/bash
#/ command: freddy:dance "watch freddy dance"
#/ usage: rerun freddy:dance 
trap 'rerun_die $? "*** command failed: freddy:dance. ***"' ERR
EOF
   mkdir -p "$first_rerun_module_dir/freddy/tests"
   cat > "$first_rerun_module_dir/freddy/tests/dance-1-test.sh" <<EOF
#!/usr/bin/env roundup
#/ usage: rerun stubbs:test -m freddy -p dance 
describe "dance"
EOF

   #
   # Create roger:
   rerun stubbs:add-module --module "roger" \
       --description "Another friend of rerun" \
       --template freddy

   # Check the metadata properties retain roger values.
   test -f "$first_rerun_module_dir/roger/metadata"
   .  "$first_rerun_module_dir/roger/metadata"
   test -n "$NAME" -a "$NAME" = roger 
   test -n "$DESCRIPTION" -a "$DESCRIPTION" = "Another friend of rerun"
   test "${VERSION}" = "1.0.0"

    # No lingering freddy text should remain.
   ! grep freddy $first_rerun_module_dir/roger/commands/*/script
   ! grep freddy $first_rerun_module_dir/roger/tests/*.sh

    # The new module name should be preserved.
   grep roger $first_rerun_module_dir/roger/commands/*/script
   grep roger $first_rerun_module_dir/roger/tests/*.sh

   rm -r  "$first_rerun_module_dir/roger"
}

it_takes_descriptions_w_commas_slashes() {
    first_rerun_module_dir=$(echo "$RERUN_MODULES" | cut -d: -f1)

    rerun stubbs:add-module --module "freddy" \
        --description "A dancer, in a red/burgundy beret"
   .  "$first_rerun_module_dir/freddy/metadata"
   test "$DESCRIPTION" = "A dancer, in a red/burgundy beret"
}
