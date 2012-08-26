# Commands covered: @COMMAND@
#
# This file contains test scripts to run for the @COMMAND@ command.
# Execute it by invoking: 
#                         rerun stubbs:test -m @MODULE@ -c @COMMAND@
#
#


# die - print an error and exit
die() { echo "ERROR: $* " ; exit 1 ; }

# Temporary directory
TMPDIR=$(mktemp -d /tmp/rerun.tests.XXXXXX) || die "failed creating temp dir" 

# Output log
OUT=$TMPDIR/$$.log

# 
# Command invocation parameters
#
RERUN_MODULES="@RERUN_MODULES@"
MODULE="@MODULE@"
COMMAND="@COMMAND@"
OPTIONS=""


#
# Extract benchamrk text
#
BENCHMARK=$TMPDIR/$MODULE:$COMMAND-$(basename $0).benchmark
SIZE=$(awk '/^__LOG_BELOW__/ {print NR + 1; exit 0; }' $0) || die "failed sizing test log"
tail -n+$SIZE $0 > $BENCHMARK || die "failed extracting benchmark text"


#
# Run the command and compare the benchmark text to the command output
#
${RERUN:=rerun} ${MODULE}:${COMMAND} $OPTIONS > $OUT
EXIT_STATUS=$?
if [ $EXIT_STATUS -eq 0 ]
then
    diff $BENCHMARK $OUT >/dev/null
    EXIT_STATUS=$?
fi

exit $EXIT_STATUS ; # exit before reading the benchmark text
__BENCHMARK_TEXT__
