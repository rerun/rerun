#!/usr/bin/env roundup
#

# Let's get started
# -----------------

# Helpers
# ------------
first_rerun_module_dir=$(echo "$RERUN_MODULES" | cut -d: -f1)

. $first_rerun_module_dir/stubbs/lib/functions.sh stubbs-functions-1-test || exit 1

rerun() {
    command $RERUN -M $RERUN_MODULES "$@"
}

before() {
    # Mock a module and command
    mkdir -p $first_rerun_module_dir/freddy
    cat > $first_rerun_module_dir/freddy/metadata <<EOF
NAME=freddy
EOF
    mkdir -p $first_rerun_module_dir/freddy/commands/dance
    cat > $first_rerun_module_dir/freddy/commands/dance/metadata <<EOF
NAME=dance
OPTIONS=
EOF

    cat > $first_rerun_module_dir/freddy/commands/dance/script <<EOF
#!/bin/bash
#/ command: freddy:dance "watch freddy dance"
#/ usage: rerun freddy:dance 
trap 'rerun_die $? "*** command failed: freddy:dance. ***"' ERR
EOF
    mkdir -p $first_rerun_module_dir/freddy/commands/study
    cat > $first_rerun_module_dir/freddy/commands/study/metadata <<EOF
NAME=study
OPTIONS=
EOF
    cat > $first_rerun_module_dir/freddy/commands/study/script <<EOF
#!/bin/bash
#/ command: freddy:study "watch freddy study"
#/ usage: rerun freddy:study 
trap 'rerun_die $? "*** command failed: freddy:study. ***"' ERR
EOF
}

after() {
    # clean up the mock module
    rm -r $first_rerun_module_dir/freddy
}


# The Plan
# --------

describe "stubbs-functions"


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
    local -a commands=( $(stubbs_option_commands $first_rerun_module_dir/freddy jumps) )
    
    rerun_list_contains dance "${commands[@]}" 
    ! rerun_list_contains study "${commands[@]}" 

    # freddy:study --jumps <3>
    rerun stubbs:add-option --module freddy --command study \
        --option jumps --description "jump #num times" \
        --required true --export true --default 3
    # Check the option-to-command assignments
    local -a commands=( $(stubbs_option_commands $first_rerun_module_dir/freddy jumps) )

    test ${#commands[*]} = 2
    rerun_list_contains dance "${commands[@]}" 
    rerun_list_contains study "${commands[@]}" 

   # Remove freddy:dance --jumps <3>
    rerun stubbs:rm-option --module freddy --command dance \
        --option jumps 

    local -a commands=( $(stubbs_option_commands $first_rerun_module_dir/freddy jumps) )

    test ${#commands[*]} = 1
    ! rerun_list_contains dance "${commands[@]}" 
    rerun_list_contains study "${commands[@]}" 
}

it_should_replace_string_in_file() {
    FILE=$(mktemp /tmp/stubbs.tests.${FUNCNAME}.XXX)
    cat >$FILE <<EOF
NAME=roger
DESCRIPTION="whats happening?"
VERSION=1
EOF
    stubbs_file_replace_str roger wiseguy $FILE
    NAME=$(awk -F= '/NAME=/ {print $2}' $FILE)
    test "$NAME" = "wiseguy"

    stubbs_file_replace_str "whats happening?" "this is happening" $FILE
    DESC=$(awk -F= '/DESCRIPTION=/ {print $2}' $FILE)
    test "$DESC" = '"this is happening"'

    stubbs_file_replace_str "VERSION=1" "VERSION=2" $FILE
    VERS=$(awk -F= '/VERSION=/ {print $2}' $FILE)
    test "$VERS" = 2

    rm $FILE
}

it_should_clone_a_module() {
    moduledir=$(mktemp -d /tmp/stubbs.tests.clone.XXX)
    cat > $moduledir/metadata <<EOF
NAME=cloney
DESCRIPTION="i am a clone"
EOF
    templatedir=$first_rerun_module_dir/freddy
    stubbs_module_clone $moduledir $templatedir

    test "$(rerun_property_get $moduledir NAME)" = "cloney"
    test "$(rerun_property_get $moduledir DESCRIPTION)" = "i am a clone"
    
    ! grep freddy $moduledir/commands/*/script
    grep cloney $moduledir/commands/*/script

    rm -rf ${moduledir}
}
