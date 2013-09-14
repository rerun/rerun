#!/usr/bin/env roundup
#

# Let's get started
# -----------------
unset RERUN_COLORS

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
    rerun_die 2>&1 |grep "^ERROR:"
    test ${PIPESTATUS[0]} = 1; # errors exit with 1
    rerun_die "messagetext" 2>&1 |grep "^ERROR: messagetext$"
    rerun_die 22 "exit code 22" 2>&1 | grep "^ERROR:"
    test ${PIPESTATUS[0]} = 22
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

    rerun_property_set $RERUN_MODULES/freddy DEFAULT="'${USER}'"
    def=$(rerun_property_get $RERUN_MODULES/freddy DEFAULT)
    test "$def" = "'${USER}'"
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
    OUT=$(mktemp "/tmp/rerun.test.XXXXX")
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
    rm ${OUT}
}

it_performs_rerun_log_puts() {
    . $RERUN
    info_level=1
    erro_level=$RERUN_LOG_ERR_LEVEL
    # Verify the default format is returned by fmt-console action.
    test "$RERUN_LOG_FMT_CONSOLE" = "$(rerun_log fmt-console)"
    # Print a message to the console
    out=($(rerun_log_puts console $info_level freddy:dance "hi there"))
    test "4" = "${#out[*]}"        
    test "[info]" = "${out[0]}"
    test "freddy:dance:" = "${out[1]}"
    message="${out[@]:2:${#out[@]}}"
    test "hi there" = "$message"
    test "[info] freddy:dance: hi there" = "${out[*]}"

    # Print an error level message and be sure it's not written to stdout.
    test -z "$(rerun_log_puts console $erro_level freddy:dance "oh no, an error")"
    # Print the message and redirect stderr to capture the output
    out=($(rerun_log_puts console $erro_level freddy:dance "oh no, an error" 2>&1))
    test -n "$out"

    # Verify the default format is returned by fmt-logfile action.
    test "$RERUN_LOG_FMT_LOGFILE" = "$(rerun_log fmt-logfile)"
    # Write a message using logfile output.
    out=($(rerun_log_puts logfile $info_level freddy:dance "hi there"))
    test "5" = "${#out[*]}"        
    test "[info]" = "${out[1]}"
    test "freddy:dance:" = "${out[2]}"
    message="${out[@]:3:${#out[@]}}"
    test "hi there" = "$message"

    # Be sure error message is is written to stderr and not stdout
    test -z "$(rerun_log_puts logfile $erro_level freddy:dance "oh no, an error")"
    out=($(rerun_log_puts logfile $erro_level freddy:dance "oh no, an error" 2>&1))
    test -n "$out"    
}

it_performs_rerun_log_level() {
    . $RERUN
    # check the default log level
    test "info" = "$(rerun_log level)"
    # Set the loglevel to warn
    rerun_log level warn
    test "warn" = "$(rerun_log level)"
    ! rerun_log level "total crap"
}

it_performs_rerun_log_levels() {
    . $RERUN
    # Get the log levels
    test -n "${RERUN_LOG_LEVELS[*]}"
    levels=($(rerun_log levels))
    test "${#levels[*]}" = "${#RERUN_LOG_LEVELS[*]}"
    test "${levels[*]}" = "${RERUN_LOG_LEVELS[*]}"
}

it_performs_rerun_log() {
    . $RERUN
    out=$(rerun_log "hi")
    test "$out" = "[info] : hi"
    out=$(rerun_log this is an unquoted message)
    test "$out" = "[info] : this is an unquoted message"    
}

it_performs_rerun_log_debug() {
    . $RERUN
    rerun_log level debug
    out=$(rerun_log debug "hi")
    test "$out" = "[debug] : hi"
}
it_performs_rerun_log_info() {
    . $RERUN
    rerun_log level info
    out=$(rerun_log info "hi")
    test "$out" = "[info] : hi"
}
it_performs_rerun_log_warn() {
    . $RERUN
    rerun_log level warn
    out=$(rerun_log warn "hi")
    test "$out" = "[warn] : hi"
}
it_performs_rerun_log_error() {
    . $RERUN
    rerun_log level error
    test -z "$(rerun_log error "hi")"
    # set the err level threshold above fatals to write to stdout 
    # and avoid getting roundup's verbose output into the stderr stream
    RERUN_LOG_ERR_LEVEL=5
    out=$(rerun_log error "hi")
    test "$out" = "[error] : hi"
}
it_performs_rerun_log_fatal() {
    . $RERUN
    rerun_log level fatal
    test -z "$(rerun_log fatal "hi")"
    # set the err level threshold above fatals to write to stdout 
    # and avoid getting roundup's verbose output into the stderr stream
    RERUN_LOG_ERR_LEVEL=6
    out=$(rerun_log fatal "hi")
    test "$out" = "[fatal] : hi"
}

it_performs_rerun_log_logfile() {
    . $RERUN
    # Get the configured logfile
    test -z "$(rerun_log logfile)"
    logfile=$(mktemp "/tmp/rerun.test.XXXXX")
    # Set the logfile
    rerun_log logfile $logfile
    test "$logfile" = $(rerun_log logfile)

    rerun_log warn "test message"
    test "1" = $(wc -l $logfile | awk '{print $1}')
    rerun_log level info
    test "1" = $(wc -l $logfile | awk '{print $1}')
    # Lower the loglevel
    rerun_log level info
    rerun_log info "info message"
    test "2" = $(wc -l $logfile | awk '{print $1}')
    grep "info message" $logfile
    rm "$logfile"
}

it_performs_rerun_log_with_command_context() {
    . $RERUN
    RERUN_MODULE_DIR=$RERUN_MODULES/freddy
    RERUN_COMMAND_DIR=$RERUN_MODULE_DIR/commands/dance
    out=$(rerun_log info "freddy says hi")
    test "[info] freddy:dance: freddy says hi" = "$out"

    out=$(rerun_log "freddy says hi")
    test "[info] freddy:dance: freddy says hi" = "$out"
}

it_performs_rerun_log_with_syslog() {
    . $RERUN
    test -z $(rerun_log syslog)
    rerun_log syslog user 
    ! rerun_log syslog "total crap"
    rerun_log "test[#$$] it_performs_rerun_log_with_syslog"
}
