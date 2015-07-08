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
    first_rerun_module_dir=$(echo "$RERUN_MODULES" | cut -d: -f1)

    mkdir -p $first_rerun_module_dir/freddy
    cat > $first_rerun_module_dir/freddy/metadata <<EOF
NAME=freddy
DESCRIPTION="mock freddy module."
EOF

    mkdir -p $first_rerun_module_dir/freddy/options/jumps
    cat > $first_rerun_module_dir/freddy/options/jumps/metadata <<EOF
NAME=jumps
DESCRIPTION="number jumps"
EOF
    mkdir -p $first_rerun_module_dir/freddy/options/slides
    cat > $first_rerun_module_dir/freddy/options/slides/metadata <<EOF
NAME=slides
DESCRIPTION="number slides"
EOF

    mkdir -p $first_rerun_module_dir/freddy/commands/dance
    cat > $first_rerun_module_dir/freddy/commands/dance/metadata <<EOF
NAME=dance
DESCRIPTION="mock dance command"
OPTIONS="jumps"
EOF

    mkdir -p $first_rerun_module_dir/freddy/commands/groove
    cat > $first_rerun_module_dir/freddy/commands/groove/metadata <<EOF
NAME=groove
DESCRIPTION="mock groove command"
OPTIONS="slides"
EOF

    mkdir -p $first_rerun_module_dir/freddy/tests
    touch $first_rerun_module_dir/freddy/tests/dance-1-test.sh 
    touch $first_rerun_module_dir/freddy/tests/groove-1-test.sh 

    return $?
}

# Remove the mock module directory.
after() {
    first_rerun_module_dir=$(echo "$RERUN_MODULES" | cut -d: -f1)

    rm -r $first_rerun_module_dir/freddy
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

    first_rerun_module_dir=$(echo "$RERUN_MODULES" | cut -d: -f1)

    ! test -d $first_rerun_module_dir/freddy/commands/dance
    ! test -d $first_rerun_module_dir/freddy/options/jumps
    ! test -f $first_rerun_module_dir/freddy/tests/dance-1-test.sh
    test -d $first_rerun_module_dir/freddy/commands/groove
    test -f $first_rerun_module_dir/freddy/tests/groove-1-test.sh    
}

# Run the command with all options.
# Be sure test and option is removed.
it_removes_specified_command() {
    rerun stubbs:rm-command --module freddy --command dance 
    first_rerun_module_dir=$(echo "$RERUN_MODULES" | cut -d: -f1)

    ! test -d $first_rerun_module_dir/freddy/commands/dance
    ! test -d $first_rerun_module_dir/freddy/options/jumps    
    ! test -f $first_rerun_module_dir/freddy/tests/dance-1-test.sh    
    test -d $first_rerun_module_dir/freddy/commands/groove    
    test -f $first_rerun_module_dir/freddy/tests/groove-1-test.sh    
}

# Create a third command that shares the "--jumps" option.
# Be sure the jumps option remains after the "dance" command is removed.
it_leaves_shared_option_if_other_command_assigned() {
    first_rerun_module_dir=$(echo "$RERUN_MODULES" | cut -d: -f1)

  mkdir -p $first_rerun_module_dir/freddy/commands/shuffle
    cat > $first_rerun_module_dir/freddy/commands/shuffle/metadata <<EOF
NAME=shuffle
DESCRIPTION="mock shuffle command"
OPTIONS="slides jumps"
EOF

    rerun stubbs:rm-command --module freddy --command dance 
    ! test -d $first_rerun_module_dir/freddy/commands/dance    
    test -d $first_rerun_module_dir/freddy/options/jumps    
}


