# Commands covered: @COMMAND@
#
# This file contains test scripts to run for the @COMMAND@ command.
# Execute it by invoking: 
#    
#                rerun stubbs:test -m @MODULE@ -c @COMMAND@
#
# The test report can be found in:
#
#                test-reports/TEST-@MODULE@:@COMMAND@.txt
#

# 
# The rerun command environment
#
RERUN="@RERUN@"
RERUN_MODULES="@RERUN_MODULES@"
# 
# Load the test function library
#
source $RERUN_MODULES/stubbs/lib/test.sh || exit 1

#
# Create a test execution session for the command
#
typeset -a test
test=( $(test:session $RERUN $RERUN_MODULES @MODULE@ @COMMAND@ "") ) || {
    test:exit 1 "error creating session" 
}

#
# test 1
#
test:pass $test || test:fail $test "test1: execution failure"

