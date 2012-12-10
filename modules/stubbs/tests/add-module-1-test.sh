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
    test -f $RERUN_MODULES/freddy/metadata
    .  $RERUN_MODULES/freddy/metadata
    test -n "$NAME" -a "$NAME" = freddy 
    test -n "$DESCRIPTION" -a "$DESCRIPTION" = "A dancer in a red beret and matching suspenders"
    test -n "$SHELL" -a "$SHELL" = "bash"
    test "$VERSION" = "1.0.0"
    grep '^REQUIRES=' $RERUN_MODULES/freddy/metadata
    grep '^EXTERNALS=' $RERUN_MODULES/freddy/metadata

}

# The Plan
# --------

describe "add-module"


it_runs_interactively() {
    rerun stubbs:add-module <<EOF
freddy
A dancer in a red beret and matching suspenders

EOF

    validate

}

it_runs_fully_optioned() {
    rerun stubbs:add-module --module "freddy" \
        --description "A dancer in a red beret and matching suspenders"

    validate
}

it_should_add_module_from_template() {

   rerun stubbs:add-module --module "freddy" \
        --description "A dancer in a red beret and matching suspenders" \

   # Create freddy:dance
   mkdir -p $RERUN_MODULES/freddy/commands/dance
   cat > $RERUN_MODULES/freddy/commands/dance/metadata <<EOF
NAME=dance
OPTIONS=
EOF
   cat > $RERUN_MODULES/freddy/commands/dance/script <<EOF
#!/bin/bash
#/ command: freddy:dance "watch freddy dance"
#/ usage: rerun freddy:dance 
trap 'rerun_die $? "*** command failed: freddy:dance. ***"' ERR
EOF
   mkdir -p $RERUN_MODULES/freddy/tests
   cat > $RERUN_MODULES/freddy/tests/dance-1-test.sh <<EOF
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
   test -f $RERUN_MODULES/roger/metadata
   .  $RERUN_MODULES/roger/metadata
   test -n "$NAME" -a "$NAME" = roger 
   test -n "$DESCRIPTION" -a "$DESCRIPTION" = "Another friend of rerun"
   test "${VERSION}" = "1.0.0"

    # No lingering freddy text should remain.
   ! grep freddy $RERUN_MODULES/roger/commands/*/script
   ! grep freddy $RERUN_MODULES/roger/tests/*.sh

    # The new module name should be preserved.
   grep roger $RERUN_MODULES/roger/commands/*/script
   grep roger $RERUN_MODULES/roger/tests/*.sh

   rm -r  $RERUN_MODULES/roger
}

it_takes_descriptions_w_commas_slashes() {
    rerun stubbs:add-module --module "freddy" \
        --description "A dancer, in a red/burgundy beret"
   .  $RERUN_MODULES/freddy/metadata
   test "$DESCRIPTION" = "A dancer, in a red/burgundy beret"
}
