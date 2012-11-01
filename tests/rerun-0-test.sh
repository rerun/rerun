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

it_performs_rerun_containsElement() {
    . $RERUN
    arr1=( one two three )
    rerun_containsElement "one" "${arr1[@]}"
    rerun_containsElement "two" "${arr1[@]}"
    rerun_containsElement "three" "${arr1[@]}"
    ! rerun_containsElement "four" "${arr1[@]}"    
}

it_performs_rerun_removeElement() {
    . $RERUN
    arr1=( one two three )    
    arr2=( $(rerun_removeElement "one" "${arr1[*]}") )
    test ${#arr2[*]} = 2
    ! rerun_containsElement "one" "${arr2[@]}"
    rerun_containsElement "two" "${arr2[@]}"
    rerun_containsElement "three" "${arr2[@]}"
}

it_performs_rerun_modules() {
    make_freddy $RERUN_MODULES

    . $RERUN
    modules=( $(rerun_modules $RERUN_MODULES) )
    test -n "$modules"
    containsElement "freddy" "${modules[@]}"
    containsElement "stubbs" "${modules[@]}"
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


it_performs_rerun_commandGetMetadataValue() {
    make_freddy $RERUN_MODULES

    . $RERUN

    name=$(rerun_commandGetMetadataValue $RERUN_MODULES/freddy dance NAME)
    test -n "$name"
    test "$name" = "dance"

}


it_performs_rerun_optionGetMetadataValue() {
    make_freddy $RERUN_MODULES

    . $RERUN

    name=$(rerun_optionGetMetadataValue $RERUN_MODULES/freddy jumps NAME)
    test -n "$name"
    test "$name" = "jumps"

    args=$(rerun_optionGetMetadataValue $RERUN_MODULES/freddy jumps ARGUMENTS)
    test -n "$args"
    test "$args" = "true"

    required=$(rerun_optionGetMetadataValue $RERUN_MODULES/freddy jumps REQUIRED)
    test -n "$required"
    test "$required" = "false"
}


it_performs_rerun_resolveCommandScript() {
    make_freddy $RERUN_MODULES

    . $RERUN
    commandScript=$(rerun_resolveCommandScript $RERUN_MODULES/freddy dance)
    test -n "$commandScript"
    test -f "$commandScript"
    test "$RERUN_MODULES/freddy/commands/dance/script" = $commandScript
}


it_performs_rerun_existsCommandScript() {
    make_freddy $RERUN_MODULES

    . $RERUN
    rerun_existsCommandScript $RERUN_MODULES/freddy dance    
    
    ! rerun_existsCommandScript $RERUN_MODULES/freddy bogus
}



it_performs_rerun_existsModule() {
    make_freddy $RERUN_MODULES

    . $RERUN
    rerun_existsModule freddy
    
    ! rerun_existsModule bogus
}

it_performs_rerunExecuteCommand() {
    make_freddy $RERUN_MODULES

    . $RERUN

    rerun_executeCommand freddy dance > $OUT
    read output < $OUT
    test "$output" = "jumps (3)"

    rerun_executeCommand freddy dance --jumps 10 > $OUT
    read output < $OUT
    test "$output" = "jumps (10)"

    rerun_executeCommand bogus xyz 2>&1 | grep "module not found: \"bogus\""

    rerun_executeCommand freddy bogus 2>&1 | grep "command not found: \"freddy:bogus\""

}


