#!/usr/bin/env roundup
#

# Let's get started
# -----------------

# Helpers
# ------------
. $RERUN_MODULES/stubbs/lib/functions.sh || exit 1

rerun() {
    command $RERUN -M $RERUN_MODULES "$@"
}

before() {
    # Mock a module and command
    mkdir -p $RERUN_MODULES/freddy
    cat > $RERUN_MODULES/freddy/metadata <<EOF
NAME=freddy
EOF
    mkdir -p $RERUN_MODULES/freddy/commands/dance
    cat > $RERUN_MODULES/freddy/commands/dance/metadata <<EOF
NAME=dance
OPTIONS=
EOF


    mkdir -p $RERUN_MODULES/freddy/commands/study
    cat > $RERUN_MODULES/freddy/commands/study/metadata <<EOF
NAME=study
OPTIONS=
EOF
}

after() {
    # clean up the mock module
    rm -r $RERUN_MODULES/freddy
}


# The Plan
# --------

describe "functions.sh"


it_performs_stubbs_option_commands() {
    # freddy:dance --jumps <3>
    rerun stubbs:add-option --module freddy --command dance \
        --option jumps --description "jump #num times" \
        --required true --export true --default 3
    # freddy:dance --music <poppin>
    rerun stubbs:add-option --module freddy --command dance \
        --option music --description "music genre" \
        --required true --export true --default poppin
    # freddy:dance --suspenders <true>
    rerun stubbs:add-option --module freddy --command dance \
        --option suspsenders --description "wear suspenders" \
        --required true --export true --default true

    # Check the option-to-command assignments
    local -a commands=( $(stubbs_option_commands $RERUN_MODULES/freddy jumps) )
    
    rerun_list_contains dance "${commands[@]}" 
    ! rerun_list_contains study "${commands[@]}" 

    # freddy:study --jumps <3>
    rerun stubbs:add-option --module freddy --command study \
        --option jumps --description "jump #num times" \
        --required true --export true --default 3
    # Check the option-to-command assignments
    local -a commands=( $(stubbs_option_commands $RERUN_MODULES/freddy jumps) )

    test ${#commands[*]} = 2
    rerun_list_contains dance "${commands[@]}" 
    rerun_list_contains study "${commands[@]}" 

   # Remove freddy:dance --jumps <3>
    rerun stubbs:rm-option --module freddy --command dance \
        --option jumps 

    local -a commands=( $(stubbs_option_commands $RERUN_MODULES/freddy jumps) )

    test ${#commands[*]} = 1
    ! rerun_list_contains dance "${commands[@]}" 
    rerun_list_contains study "${commands[@]}" 
}
