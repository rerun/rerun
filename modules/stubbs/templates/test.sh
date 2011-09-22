# This is a rerun command unit test script
# 
# metadata
RERUN_MODULES="@RERUN_MODULES@"
MODULE="@MODULE@"
COMMAND="@COMMAND@"
OPTIONS="$*"

# die - print an error and exit
die() { echo "ERROR: $* " ; exit 1 ; }

# Extract execution log content
TMPDIR=$(mktemp -d /tmp/rerun.tests.XXXXXX) || die; # save it here
SIZE=$(awk '/^__LOG_BELOW__/ {print NR + 1; exit 0; }' $0) || die "failed sizing test log"
tail -n+$SIZE $0 > $TMPDIR/$(basename $0) || die "failed extracting test log"

# Execute the command
${RERUN:=rerun} ${MODULE}:${COMMAND} $OPTIONS 2>&1 | tee $TMPDIR/$$.log || die
# Compare the results
diff $TMPDIR/$(basename $0) $TMPDIR/$$.log

exit $? ; # exit before reading the log content
__LOG_BELOW__
