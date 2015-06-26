#!/usr/bin/env roundup
#

# Let's get started
# -----------------
unset RERUN_COLOR

# Helpers
# ------------
for i in ./functions.sh ../tests/functions.sh `dirname $1`/functions.sh `dirname $0`/functions.sh
do
  if [ -r ${i} ]; then
    . ${i} || { echo "Failed loading test functions" ; exit 2 ; }
    break
  fi
done

rerun() {
    command $RERUN "$@"
}

# The Plan
# --------

describe "rerun(0) Function library tests"

it_can_be_sourced() {
    OUT=$(mktemp "/tmp/rerun.test.XXXXX")
    . $RERUN > $OUT 
    ! test -s $OUT 

    test -n "$RERUN_VERSION"
    test -n "$RERUN"
    rm ${OUT}
}

it_performs_rerun_die() {
    . $RERUN
    rerun_die 2>&1 |grep "ERROR:"
    test ${PIPESTATUS[0]} = 1; # errors exit with 1
    rerun_die "messagetext" 2>&1 |grep "ERROR: messagetext$"
    rerun_die 22 "exit code 22" 2>&1 | grep "ERROR:"
    test ${PIPESTATUS[0]} = 22
}

it_performs_rerun_syntax_error() {
    . $RERUN
    rerun_syntax_error 2>&1 |grep "SYNTAX:"
    test ${PIPESTATUS[0]} = 2; # syntax errors exit with 2
    rerun_syntax_error "messagetext" 2>&1 |grep "SYNTAX: messagetext$"
}

it_performs_rerun_option_check() {
    . $RERUN
    rerun_option_check 1 foo 2>&1 |grep "SYNTAX: option requires argument: foo"
    test ${PIPESTATUS[0]} = 2; # syntax errors exit with 2

    rerun_option_check 2 bar 
}

it_performs_rerun_options_parse() {
    . $RERUN
    rerun_options_parse -h 2>&1 |grep "^usage: "
    test ${PIPESTATUS[0]} = 2; # syntax errors exit with 2

    rerun_options_parse 2 bar 
}

it_performs_rerun_path_absolute() {
    . $RERUN
    expr "$(rerun_path_absolute $RERUN)" : "/.*"
}

it_performs_rerun_list_contains() {
    . $RERUN
    arr1=( one two three )
    rerun_list_contains "one" "${arr1[@]}"
    rerun_list_contains "two" "${arr1[@]}"
    rerun_list_contains "three" "${arr1[@]}"
    ! rerun_list_contains "four" "${arr1[@]}"    

    options=( content-type description file owner repository url )
    rerun_list_contains "url" "${options[@]}"

    #rerun_list_contains title 'url owner repository title key-file'
    options=(url owner repository title key-file)
    rerun_list_contains title "${options[@]}"
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

it_performs_rerun_list_index() {
    . $RERUN
    arr1=( zero one two three four )
    test "0" = $(rerun_list_index zero  "${arr1[@]}")
    test "1" = $(rerun_list_index one   "${arr1[@]}")
    test "2" = $(rerun_list_index two   "${arr1[@]}")
    test "3" = $(rerun_list_index three "${arr1[@]}")
    test "4" = $(rerun_list_index four  "${arr1[@]}")
    test "-1" = $(rerun_list_index five  "${arr1[@]}")
}

it_performs_rerun_modules() {
    . $RERUN
    make_freddy $(rerun_module_path_elements $RERUN_MODULES | head -1)
    modules=( $(rerun_modules $RERUN_MODULES) )
    test -n "$modules"
    rerun_list_contains "freddy" "${modules[@]}"
    containsElement "stubbs" "${modules[@]}"
}

it_performs_get_module_home_dir_in_path() {
    modules1=$(mktemp -d "/tmp/rerun.modules.XXXXX")
    modules2=$(mktemp -d "/tmp/rerun.modules.XXXXX")
    make_freddy $modules1
    mv $modules1/freddy $modules1/berrie
    make_freddy $modules2
    RERUN_MODULES=$modules1:$modules2
    
    . $RERUN
    home_dir=$(rerun_get_module_home_dir_in_path $RERUN_MODULES freddy)
    test $home_dir = $modules2/freddy
    home_dir=$(rerun_get_module_home_dir_in_path $RERUN_MODULES berrie)
    test $home_dir = $modules1/berrie
    rm -rf ${modules1}/berrie
    ! rerun_get_module_home_dir_in_path $RERUN_MODULES berrie
    rmdir ${modules1}
    rm -rf ${modules2}/freddy
    rmdir ${modules2}

}


it_performs_rerun_module_options() {
    . $RERUN
    make_freddy $(rerun_module_path_elements $RERUN_MODULES | head -1)
    options=( $(rerun_module_options $RERUN_MODULES freddy) )
    test -n "$options"
    test "${#options[*]}" = 2
    rerun_list_contains "jumps" "${options[@]}"
}

it_performs_rerun_commands() {
    . $RERUN
    make_freddy $(rerun_module_path_elements $RERUN_MODULES | head -1)
    commands=( $(rerun_commands $RERUN_MODULES freddy) )
    test -n "$commands"
    test "${#commands[*]}" = 2
    containsElement "dance" "${commands[@]}"
}


it_performs_rerun_options() {
    . $RERUN
    make_freddy $(rerun_module_path_elements $RERUN_MODULES | head -1)
    options=( $(rerun_options $RERUN_MODULES freddy dance) )
    test -n "$options"
    test "${#options[*]}" = 1
    containsElement "jumps" "${options[@]}"
}


it_performs_rerun_property_get() {
    . $RERUN
    MODULE_PATH="$(rerun_module_path_elements $RERUN_MODULES | head -1)"
    make_freddy $MODULE_PATH

    # Get metadata property from module
    name=$(rerun_property_get $MODULE_PATH/freddy NAME)
    test -n "$name"
    test "$name" = "freddy"

    # Get metadata property for a command.
    name=$(rerun_property_get $MODULE_PATH/freddy/commands/dance NAME)
    test -n "$name"
    test "$name" = "dance"

    # Get option metadata property
    name=$(rerun_property_get $MODULE_PATH/freddy/options/jumps NAME)
    test -n "$name"
    test "$name" = "jumps"

    args=$(rerun_property_get $MODULE_PATH/freddy/options/jumps ARGUMENTS)
    test -n "$args"
    test "$args" = "true"

    required=$(rerun_property_get $MODULE_PATH/freddy/options/jumps REQUIRED)
    test -n "$required"
    test "$required" = "false"

    # Test negative results

    # Should fail when getting a non existent metadata property
    ! rerun_property_get  $MODULE_PATH/freddy BOGUS$$

    # Should fail when accessing a missing metadata file
    ! rerun_property_get GARBAGEDIR 2>&1 |grep "metadata not found: GARBAGEDIR"
}

it_performs_rerun_property_get_with_expand() {
    . $RERUN
    DIR=$(mktemp -d "/tmp/rerun.test.XXXXX")

    # Declare variables in the environment
    URL="http://localhost:8080"
    DESCRIPTION="A whitespace separated string"

    cat > $DIR/metadata <<EOF
NAME=url
DESCRIPTION=\$DESCRIPTION
ARGUMENTS=true
REQUIRED=true
SHORT=
LONG=url
DEFAULT=\$URL
EXPORT=false
EOF

    # With expand=false should return the unexpanded variable
    test "$(rerun_property_get $DIR DEFAULT false)" = '$URL'
    test "$(rerun_property_get $DIR DEFAULT true)" = "http://localhost:8080"

    test "$(rerun_property_get $DIR DESCRIPTION true)" = "A whitespace separated string"
    test "$(rerun_property_get $DIR DESCRIPTION false)" = '$DESCRIPTION'

    # Test the default behavior when no expand flag is passed.
    test "$(rerun_property_get $DIR DEFAULT)" = 'http://localhost:8080'
    ! test "$(rerun_property_get $DIR DEFAULT)" = '$URL'

    rm -r $DIR
}

it_performs_rerun_property_set() {
    . $RERUN
    MODULE_DIR="$(rerun_module_path_elements $RERUN_MODULES | head -1)"
    make_freddy $MODULE_DIR

    desc=$(rerun_property_get $MODULE_DIR/freddy DESCRIPTION)
    test "$desc" = "A dancer in a red beret and matching suspenders"

    rerun_property_set $MODULE_DIR/freddy DESCRIPTION=nothing
    desc=$(rerun_property_get $MODULE_DIR/freddy DESCRIPTION)
    test "$desc" = "nothing"

    rerun_property_set $MODULE_DIR/freddy DESCRIPTION="the poppin dancer"
    desc=$(rerun_property_get $MODULE_DIR/freddy DESCRIPTION)
    test "$desc" = "the poppin dancer"


    rerun_property_set $MODULE_DIR/freddy ONE=1 TWO=2 THREE=3
    one=$(rerun_property_get $MODULE_DIR/freddy ONE)
    test "$one" = "1"

    two=$(rerun_property_get $MODULE_DIR/freddy TWO)
    test "$two" = "2"

    three=$(rerun_property_get $MODULE_DIR/freddy THREE)
    test "$three" = "3"

    rerun_property_set $MODULE_DIR/freddy DEFAULT="'${USER}'"
    def=$(rerun_property_get $MODULE_DIR/freddy DEFAULT)
    test "$def" = "'${USER}'"
}


it_performs_rerun_module_exists_multiple() {
    modules1=$(mktemp -d "/tmp/rerun.modules.XXXXX")
    modules2=$(mktemp -d "/tmp/rerun.modules.XXXXX")
    make_freddy $modules1
    make_freddy $modules2
    RERUN_MODULES=$modules1:$modules2
    
    . $RERUN
    home_dir=$(rerun_module_exists freddy)
    test $home_dir = $modules1/freddy
    rm -rf ${modules1}/freddy
    home_dir=$(rerun_module_exists freddy)
    test $home_dir = $modules2/freddy
    rmdir ${modules1}
    rm -rf ${modules2}/freddy
    rmdir ${modules2}
}


it_performs_rerun_script_lookup() {
    . $RERUN
    MODULE_DIR="$(rerun_module_path_elements $RERUN_MODULES | head -1)"
    make_freddy $MODULE_DIR
    
    commandScript=$(rerun_script_lookup $MODULE_DIR/freddy dance)
    test -n "$commandScript"
    test -f "$commandScript"
    test "$MODULE_DIR/freddy/commands/dance/script" = $commandScript
}


it_performs_rerun_script_exists() {
    . $RERUN 
    MODULE_DIR="$(rerun_module_path_elements $RERUN_MODULES | head -1)"
    make_freddy $MODULE_DIR

    rerun_script_exists $MODULE_DIR/freddy dance    
    
    ! rerun_script_exists $MODULE_DIR/freddy bogus
}



it_performs_rerun_module_exists() {
    . $RERUN
    make_freddy $(rerun_module_path_elements $RERUN_MODULES | head -1)
    rerun_module_exists freddy
    
    ! rerun_module_exists bogus
}

it_performs_rerun_command_execute() {
    . $RERUN

    OUT=$(mktemp "/tmp/rerun.test.XXXXX")
    make_freddy $(rerun_module_path_elements $RERUN_MODULES | head -1)

    rerun_command_execute freddy dance > $OUT
    read output < $OUT
    test "$output" = "jumps (3)"

    rerun_command_execute freddy dance --jumps 10 > $OUT
    read output < $OUT
    test "$output" = "jumps (10)"

    rerun_command_execute bogus xyz 2>&1 | grep "module not found: \"bogus\""

    rerun_command_execute freddy bogus 2>&1 | grep "command not found: \"freddy:bogus\""
    rm ${OUT}
}
