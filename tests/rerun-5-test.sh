#!/usr/bin/env roundup
#

# Let's get started
# -----------------
unset RERUN_COLOR
RERUN_LOG_FMT_CONSOLE="[%level%] %command%: %message%"

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

describe "rerun(5) Log function tests"


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
}

it_performs_logs_error_to_console() {    
    . $RERUN
    erro_level=$RERUN_LOG_ERR_LEVEL
    # Print an error level message and be sure it's not written to stdout.
    test -z "$(rerun_log_puts console "$erro_level" freddy:dance "oh no, an error")"
    # Print the message and redirect stderr to capture the output
    out=($(rerun_log_puts console "$erro_level" freddy:dance "oh no, an error" 2>&1))
    test -n "${out[0]}"
}

it_performs_log_fmt_logfile() {    
    . $RERUN

    # Verify the default format is returned by fmt-logfile action.
    test "$RERUN_LOG_FMT_LOGFILE" = "$(rerun_log fmt-logfile)"
    # Write a message using logfile output.
    out=($(rerun_log_puts logfile 1 freddy:dance "hi there"))
    test "5" = "${#out[*]}"        
    test "[info]" = "${out[1]}"
    test "freddy:dance:" = "${out[2]}"
    message=${out[*]:3:${#out[*]}}
    test "hi there" = "$message"
}

it_performs_log_error_level() {    
    . $RERUN
    local erro_level=$RERUN_LOG_ERR_LEVEL

    # Be sure error message is is written to stderr and not stdout
    test -z "$(rerun_log_puts logfile "$erro_level" freddy:dance "oh no, an error")"
    out=($(rerun_log_puts logfile "$erro_level" freddy:dance "oh no, an error" 2>&1))
    test -n "${out[*]}"    
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

it_prints_unexpanded_glob_string() {
    . $RERUN
    out=$(rerun_log info "*** hi ***")
    test "$out" = '[info] : *** hi ***'
}
