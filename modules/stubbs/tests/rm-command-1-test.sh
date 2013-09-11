#!/usr/bin/env roundup
#

# Let's get started
# -----------------

# Helpers
# -------
. "$RERUN" || exit 1 ;

# A helper to run rerun.
rerun() {
    command $RERUN -M $RERUN_MODULES "$@"
}

#
# Mock a freddy module with two commands and two options.
#
before() {
    mkdir -p $RERUN_MODULES/freddy
    cat > $RERUN_MODULES/freddy/metadata <<EOF
NAME=freddy
DESCRIPTION="mock freddy module."
EOF

    mkdir -p $RERUN_MODULES/freddy/options/jumps
    cat > $RERUN_MODULES/freddy/options/jumps/metadata <<EOF
NAME=jumps
DESCRIPTION="number jumps"
EOF
    mkdir -p $RERUN_MODULES/freddy/options/slides
    cat > $RERUN_MODULES/freddy/options/slides/metadata <<EOF
NAME=slides
DESCRIPTION="number slides"
EOF

    mkdir -p $RERUN_MODULES/freddy/commands/dance
    cat > $RERUN_MODULES/freddy/commands/dance/metadata <<EOF
NAME=dance
DESCRIPTION="mock dance command"
OPTIONS="jumps"
EOF

    mkdir -p $RERUN_MODULES/freddy/commands/groove
    cat > $RERUN_MODULES/freddy/commands/groove/metadata <<EOF
NAME=groove
DESCRIPTION="mock groove command"
OPTIONS="slides"
EOF

    mkdir -p $RERUN_MODULES/freddy/tests
    touch $RERUN_MODULES/freddy/tests/dance-1-test.sh 
    touch $RERUN_MODULES/freddy/tests/groove-1-test.sh 

    return $?
}

# Remove the mock module directory.
after() {
    rm -r $RERUN_MODULES/freddy
}


# The Plan
# --------

describe "rm-command"

# The Tests
# ---------

# Run it in interactive mode and be sure it prompts for command.
it_prompts_user_for_command() {
    rerun stubbs:rm-command --module freddy<<EOF
1
EOF

    ! test -d $RERUN_MODULES/freddy/commands/dance
    ! test -d $RERUN_MODULES/freddy/options/jumps
    ! test -f $RERUN_MODULES/freddy/tests/dance-1-test.sh
    test -d $RERUN_MODULES/freddy/commands/groove
    test -f $RERUN_MODULES/freddy/tests/groove-1-test.sh    
}

# Run the command with all options.
# Be sure test and option is removed.
it_removes_specified_command() {
    rerun stubbs:rm-command --module freddy --command dance 
    ! test -d $RERUN_MODULES/freddy/commands/dance
    ! test -d $RERUN_MODULES/freddy/options/jumps    
    ! test -f $RERUN_MODULES/freddy/tests/dance-1-test.sh    
    test -d $RERUN_MODULES/freddy/commands/groove    
    test -f $RERUN_MODULES/freddy/tests/groove-1-test.sh    
}

# Create a third command that shares the "--jumps" option.
# Be sure the jumps option remains after the "dance" command is removed.
it_leaves_shared_option_if_other_command_assigned() {
  mkdir -p $RERUN_MODULES/freddy/commands/shuffle
    cat > $RERUN_MODULES/freddy/commands/shuffle/metadata <<EOF
NAME=shuffle
DESCRIPTION="mock shuffle command"
OPTIONS="slides jumps"
EOF

    rerun stubbs:rm-command --module freddy --command dance 
    ! test -d $RERUN_MODULES/freddy/commands/dance    
    test -d $RERUN_MODULES/freddy/options/jumps    
}


