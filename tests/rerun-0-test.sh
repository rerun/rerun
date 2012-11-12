#!/usr/bin/env roundup
#

# Let's get started
# -----------------
unset RERUN_COLORS

# Helpers
# ------------
. ./functions.sh || { echo "Failed loading test functions" ; exit 2 ; }

rerun() {
    command $RERUN "$@"
}

before() {
    OUT=$(mktemp "/tmp/rerun.test.XXXXX")
}

after() {
    rm $OUT
}

# The Plan
# --------

describe "rerun(0) Function library tests"

it_can_be_sourced() {
    . $RERUN > $OUT 
    ! test -s $OUT 

    test -n "$RERUN_VERSION"
    test -n "$RERUN"
}

it_performs_rerun_die() {
    . $RERUN
    rerun_die 2>&1 |grep "^ERROR:"
    test ${PIPESTATUS[0]} = 1; # errors exit with 1
    rerun_die "messagetext" 2>&1 |grep "^ERROR: messagetext$"
}

it_performs_rerun_syntax_error() {
    . $RERUN
    rerun_syntax_error 2>&1 |grep "^SYNTAX:"
    test ${PIPESTATUS[0]} = 2; # syntax errors exit with 2
    rerun_syntax_error "messagetext" 2>&1 |grep "^SYNTAX: messagetext$"
}

it_performs_rerun_option_check() {
    . $RERUN
    rerun_option_check 1 foo 2>&1 |grep "^SYNTAX: option requires argument: foo"
    test ${PIPESTATUS[0]} = 2; # syntax errors exit with 2

    rerun_option_check 2 bar 
}

it_performs_rerun_options_parse() {
    . $RERUN
    rerun_options_parse -h 2>&1 |grep "^usage: "
    test ${PIPESTATUS[0]} = 2; # syntax errors exit with 2

    rerun_options_parse 2 bar 
}

it_performs_rerun_list_contains() {
    . $RERUN
    arr1=( one two three )
    rerun_list_contains "one" "${arr1[@]}"
    rerun_list_contains "two" "${arr1[@]}"
    rerun_list_contains "three" "${arr1[@]}"
    ! rerun_list_contains "four" "${arr1[@]}"    
}

it_performs_rerun_list_remove() {
    . $RERUN
    arr1=( one two three )    
    arr2=( $(rerun_list_remove "one" "${arr1[*]}") )
    test ${#arr2[*]} = 2
    ! rerun_list_contains "one" "${arr2[@]}"
    rerun_list_contains "two" "${arr2[@]}"
    rerun_list_contains "three" "${arr2[@]}"
}

it_performs_rerun_modules() {
    make_freddy $RERUN_MODULES

    . $RERUN
    modules=( $(rerun_modules $RERUN_MODULES) )
    test -n "$modules"
    rerun_list_contains "freddy" "${modules[@]}"
    containsElement "stubbs" "${modules[@]}"
}

it_performs_rerun_module_options() {
    make_freddy $RERUN_MODULES

    . $RERUN
    options=( $(rerun_module_options $RERUN_MODULES freddy) )
    test -n "$options"
    test "${#options[*]}" = 2
    rerun_list_contains "jumps" "${options[@]}"
}

it_performs_rerun_commands() {
    make_freddy $RERUN_MODULES

    . $RERUN
    commands=( $(rerun_commands $RERUN_MODULES freddy) )
    test -n "$commands"
    test "${#commands[*]}" = 2
    containsElement "dance" "${commands[@]}"
}


it_performs_rerun_options() {
    make_freddy $RERUN_MODULES

    . $RERUN
    options=( $(rerun_options $RERUN_MODULES freddy dance) )
    test -n "$options"
    test "${#options[*]}" = 1
    containsElement "jumps" "${options[@]}"
}


it_performs_rerun_property_get() {
    make_freddy $RERUN_MODULES

    . $RERUN

    # Get metadata property from module
    name=$(rerun_property_get $RERUN_MODULES/freddy NAME)
    test -n "$name"
    test "$name" = "freddy"

    # Get metadata property for a command.
    name=$(rerun_property_get $RERUN_MODULES/freddy/commands/dance NAME)
    test -n "$name"
    test "$name" = "dance"

    # Get option metadata property
    name=$(rerun_property_get $RERUN_MODULES/freddy/options/jumps NAME)
    test -n "$name"
    test "$name" = "jumps"

    args=$(rerun_property_get $RERUN_MODULES/freddy/options/jumps ARGUMENTS)
    test -n "$args"
    test "$args" = "true"

    required=$(rerun_property_get $RERUN_MODULES/freddy/options/jumps REQUIRED)
    test -n "$required"
    test "$required" = "false"

    # Test negative results
    ! rerun_property_get  $RERUN_MODULES/freddy BOGUS$$

    ! rerun_property_get GARBAGEDIR 2>&1 |grep "metadata not found: GARBAGEDIR"
}


it_performs_rerun_property_set() {
    make_freddy $RERUN_MODULES

    . $RERUN

    desc=$(rerun_property_get $RERUN_MODULES/freddy DESCRIPTION)
    test "$desc" = "A dancer in a red beret and matching suspenders"

    rerun_property_set $RERUN_MODULES/freddy DESCRIPTION=nothing
    desc=$(rerun_property_get $RERUN_MODULES/freddy DESCRIPTION)
    test "$desc" = "nothing"

    rerun_property_set $RERUN_MODULES/freddy DESCRIPTION="the poppin dancer"
    desc=$(rerun_property_get $RERUN_MODULES/freddy DESCRIPTION)
    test "$desc" = "the poppin dancer"


    rerun_property_set $RERUN_MODULES/freddy ONE=1 TWO=2 THREE=3
    one=$(rerun_property_get $RERUN_MODULES/freddy ONE)
    test "$one" = "1"

    two=$(rerun_property_get $RERUN_MODULES/freddy TWO)
    test "$two" = "2"

    three=$(rerun_property_get $RERUN_MODULES/freddy THREE)
    test "$three" = "3"

}

it_performs_rerun_script_lookup() {
    make_freddy $RERUN_MODULES

    . $RERUN
    commandScript=$(rerun_script_lookup $RERUN_MODULES/freddy dance)
    test -n "$commandScript"
    test -f "$commandScript"
    test "$RERUN_MODULES/freddy/commands/dance/script" = $commandScript
}


it_performs_rerun_script_exists() {
    make_freddy $RERUN_MODULES

    . $RERUN
    rerun_script_exists $RERUN_MODULES/freddy dance    
    
    ! rerun_script_exists $RERUN_MODULES/freddy bogus
}



it_performs_rerun_module_exists() {
    make_freddy $RERUN_MODULES

    . $RERUN
    rerun_module_exists freddy
    
    ! rerun_module_exists bogus
}

it_performs_rerun_command_execute() {
    make_freddy $RERUN_MODULES

    . $RERUN

    rerun_command_execute freddy dance > $OUT
    read output < $OUT
    test "$output" = "jumps (3)"

    rerun_command_execute freddy dance --jumps 10 > $OUT
    read output < $OUT
    test "$output" = "jumps (10)"

    rerun_command_execute bogus xyz 2>&1 | grep "module not found: \"bogus\""

    rerun_command_execute freddy bogus 2>&1 | grep "command not found: \"freddy:bogus\""

}


