#!/usr/bin/env roundup
#

# Let's get started
# -----------------
unset RERUN_COLORS


# Helpers
# ------------
source ./functions.sh || { echo "Failed loading test functions" ; exit 2 ; }

rerun() {
    command $RERUN "$@"
}


rerun_extractLog() {
	file=$1
	[ -f $file ] || die "file does not exist: $file"
	SIZE=$(awk '/^__LOG_BELOW__/ {print NR + 1; exit 0; }' $file) || die "failed sizing log"
	tail -n+$SIZE $file || die "failed extracting log"
}




# The Plan
# --------

describe "rerun(3) Replay logging"


it_writes_replay_to_logdir() {
    logdir=$(mktemp -d "/tmp/rerun-test-logs.XXX")
    make_freddy $RERUN_MODULES
    out=$(rerun -L $logdir freddy:dance --jumps 5)
    test "$out" = "jumps (5)"
    TSTAMP=$(date '+%Y-%m-%dT%H%M%S-%Z')
    test -L $logdir/freddy-dance-latest.replay
    head -10  $logdir/freddy-dance-latest.replay > $logdir/replay.metadata
    source $logdir/replay.metadata
    test "$MODULE" = "freddy"
    test "$COMMAND" = "dance"
    test "$OPTIONS" = "--jumps 5"
    test -n "DATE"
    test "$EXIT_STATUS" = "0"

    rerun_extractLog $logdir/freddy-dance-latest.replay > $logdir/replay.extract
    grep -q 'jumps (5)' $logdir/replay.extract
}

it_runs_replay() {
    logdir=$(mktemp -d "/tmp/rerun-test-logs.XXX")
    make_freddy $RERUN_MODULES
    rerun -L $logdir freddy:dance --jumps 5
    rerun -L $logdir freddy:dance --jumps 6
    rerun -L $logdir freddy:dance --jumps 7

    # sort log files so earliest are first in the list.
    logs=( $(ls -rt $logdir) )

    # Should have 3 recorded executions + 1 symlink.
    test ${#logs[*]} = 4
  
    # Repeat executions should succeed.
    last=$(readlink $logdir/freddy-dance-latest.replay)
    rerun -L $logdir --replay $last freddy:dance --jumps 7

    # Run it like the first time.
    rerun -L $logdir --replay $logdir/${logs[0]} freddy:dance --jumps 5

    # This should never match and produce a diff
    rerun -L $logdir --replay $logdir/${logs[2]} freddy:dance --jumps $$ | grep '\[diff]'
	test "${PIPESTATUS[0]}" = 1

}
