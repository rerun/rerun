#!/bin/bash
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
	-name)
	    rerun_syntax_check "$#"
	    NAME="$2"
	    shift
	    ;;
	-logs)
	    rerun_syntax_check "$#"
	    LOGS="$2"
	    shift
	    ;;	
    # unknown option
	-?)
	    rerun_syntax_error
	    ;;
	  # end of options, just arguments left
	*)
	    break
    esac
    shift
done

# Post processes the options
[ -z "$NAME" ] && {
    echo "Module name: "
    read NAME
}
[ -d $RERUN_MODULES/$NAME ] || rerun_die "Module directory not found: $RERUN_MODULES/$NAME"
#
# set some defaults
[ -z "$LOGS" ] && LOGS="./test-reports"

mkdir -p $LOGS || rerun_die "Failed making logs directory: $LOGS"


FAILURES=0 ;# test failure counter
ELAPSED=   ;# total elapsed time
shopt -s nullglob

# epoch - return number seconds since unix epoch
epoch() { date "+%s" ; }

START=$(epoch)
echo "[tests]"
for command in $(rerun_commands $RERUN_MODULES $NAME)
do	
	TESTS=( $(rerun_tests $RERUN_MODULES $NAME $command) )
	for test in $TESTS
	do
		LOG=$LOGS/TEST-${NAME}:${command}.$test.txt
		test_descr=$(rerun_testDescription $RERUN_MODULES $NAME $command)
		printf "${PAD}$command: $test_descr: $test: "
		(
		unset RERUN_COLORS
		$RERUN -M $RERUN_MODULES/${NAME} \
			   -L $LOGS \
			tests:$command > $LOG 2> $LOG.stderr
		)
		if [ "$?" != 0 ]
		then
			FAILURES=$(( $FAILURES + 1 ))
			printf "FAIL\n"
		else
			printf "OK\n"
		fi
	done
	END=$(epoch)
	ELAPSED=$(( $END - $START ))
	# Report header
	(
	cat <<-EOF
	Testsuite: ${NAME}:${command}
	Tests run: ${#TESTS[*]}, Failures: ${FAILURES}, Time elapsed: $ELAPSED s

	EOF
	) > $LOGS/TEST-${NAME}:${command}.txt	
done
# Generate report
END=$(epoch)
ELAPSED=$(( $END - $START ))
(
cat <<-EOF
Testsuite: ${NAME}
Tests run: ${#TESTS[*]}, Failures: ${FAILURES}, Time elapsed: $ELAPSED s

EOF
) > $LOGS/TEST-${NAME}.txt

(( $FAILURES > 0 )) && exit 1

# Done

