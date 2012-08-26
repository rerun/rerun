#!/usr/bin/env bash
#
# NAME
#
#   test
#
# DESCRIPTION
#
#   run module test scripts
#

# Source common function library
source $RERUN_MODULES/stubbs/lib/functions.sh || { echo "failed laoding function library" ; exit 1 ; }
PAD="  "

rerun_init

# Get the options
while [ "$#" -gt 0 ]; do
    OPT="$1"
    case "$OPT" in
        # options without arguments
	# options with arguments
	-m|--module)
	    rerun_option_check "$#"
	    MODULE="$2"
	    shift
	    ;;
	-c|--command)
	    rerun_option_check "$#"
	    COMMAND="$2"
	    shift
	    ;;
	-l|--logs)
	    rerun_option_check "$#"
	    LOGS="$2"
	    shift
	    ;;	
    # unknown option
	-?)
	    rerun_option_error
	    ;;
	  # end of options, just arguments left
	*)
	    break
    esac
    shift
done

# Post processes the options
[ -z "$MODULE" ] && {
    echo "Module name: "
    read MODULE
}
[ -d $RERUN_MODULES/$MODULE ] || rerun_die "Module directory not found: $RERUN_MODULES/$MODULE"
[ -z "$LOGS" ] && LOGS="./test-reports"

#
# Make the log directories
#
mkdir -p $LOGS || rerun_die "Failed making logs directory: $LOGS"
mkdir -p $LOGS/replay || rerun_die "Failed making replay directory: $LOGS/replay"

epoch() { date "+%s" ; };# epoch - return number seconds since unix epoch

#
# Initialize the counters
#
FAILURES=0 ;# test failure counter
ELAPSED=   ;# total elapsed time
START=$(epoch)

echo "------------- ---------------- ---------------" > /tmp/hr.txt


echo "[tests]"

shopt -s nullglob

COMMANDS=
if [ -n "$COMMAND" ]
then
    COMMANDS=( $COMMAND )
else
    COMMANDS=$(rerun_commands $RERUN_MODULES $MODULE)
fi

for command in $COMMANDS
do	
    # Logs to store the stout/stderr for the command testsuite
    OUT=$LOGS/TEST-${MODULE}:${command}.stdout
    ERR=$LOGS/TEST-${MODULE}:${command}.stderr
    echo "------------- Standard Output ---------------" > $OUT
    echo "------------- Standard Error ----------------" > $ERR
    
    TESTS=( $(rerun_tests $RERUN_MODULES $MODULE $command) )
    for test in $TESTS
    do
	echo "--Output from ${test}--" >> $OUT
	echo "--Output from ${test}--" >> $ERR

	test_descr=$(rerun_testDescription $RERUN_MODULES $MODULE $command)
	printf "${PAD}$MODULE:$command: "
	(
	    unset RERUN_COLORS
	    $RERUN -M $RERUN_MODULES/${MODULE} \
		tests:$command >> $OUT 2>> $ERR
	)
	if [ "$?" -eq 0 ]
	then
	    printf "OK\n"
	else
	    FAILURES=$(( $FAILURES + 1 ))
	    printf "FAIL\n"
	fi

    done
    END=$(epoch)
    ELAPSED=$(( $END - $START ))
	# Report header
    (
	cat <<-EOF
	Testsuite: ${MODULE}:${command}
	Tests run: ${#TESTS[*]}, Failures: ${FAILURES}, Time elapsed: ${ELAPSED}s

	EOF
    ) > $LOGS/TEST-${MODULE}:${command}.summary
    cat $LOGS/TEST-${MODULE}:${command}.summary \
	$OUT /tmp/hr.txt $ERR /tmp/hr.txt > $LOGS/TEST-${MODULE}:${command}.txt
done

#
# Generate report
#
END=$(epoch)
ELAPSED=$(( $END - $START ))
(
    cat <<-EOF
Testsuite: ${MODULE}
Tests run: ${#TESTS[*]}, Failures: ${FAILURES}, Time elapsed: ${ELAPSED}s

EOF
) > $LOGS/TEST-${MODULE}.txt

(( $FAILURES > 0 )) && exit 1

# Done

