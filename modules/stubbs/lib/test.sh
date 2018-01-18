#
# Test function library
# 
# This file contains a collection of shell functions useful 
# for testing rerun modules via stubbs. 
#
# Example: Test the freddy:dance command 
#
#      
#      # 
#      # The rerun command environment
#      #
#      RERUN=rerun
#      RERUN_MODULES="/Users/alexh/rerun-workspace/rerun/modules"
#      # 
#      # Load the test function library
#      #
#      source $RERUN_MODULE_DIR/lib/test.sh || exit 1
#       
#      #
#      # Create a test execution session for the command
#      #
#      typeset -a test
#      test=( $(test:session $RERUN $RERUN_MODULES freddy dance "") ) || {
#          test:exit 1 "error creating session" 
#      }
#       
#      test:pass $test || test:fail $test "execution failure"
#       
#      test:equals $test "" "jumps (1)" || test:fail $test "no options default value"
#       
#      test:equals $test "--jumps 3"  "jumps (3)" || test:fail $test "jumps specified 3" 
#       
#      test:equals $test "--jumps up" "jumps (up)" || test:fail $test "jumps specified up"



# ----------------------------------------------------------- 
#
# test:log --
#
#      Prints your message to stdout.
#
# ----------------------------------------------------------- 

function test:log {
    echo "$*"
}

# ----------------------------------------------------------- 
#
# test:exit --
#
#      Prints your message and exits with specified exit code. 
#      If the exit code is not specified, 0 is the default.
#      If an exit code of 1 is specified, your message is printed
#      to the stderr channel.
#
# Side effects:
#      Removes the session directory
#      Shell exit
#
# ----------------------------------------------------------- 

function test:exit {
    [ ! $# -eq 3 ] && { 
	    test:die 'wrong # args: should be: test:exit directory code msg'
    }

    DIRECTORY=$1
    EXIT_CODE=$2
    MESSAGE=$3

    if [ "$EXIT_CODE" == 0 ]
    then 
	    test:log $MESSAGE
    else
	    test:log $MESSAGE >&2
    fi

    rm -r $DIRECTORY || echo "failed removing session directory"
    exit ${EXIT_CODE}
}



# ----------------------------------------------------------- 
#
# test:die --
#
#      This function prints a message and returns.
#      If a message is specified it is written to stderr.
#
# Results:
#      return 5
#
# ----------------------------------------------------------- 

function test:die {
    test:log $* >&2
    return 5
}


# ----------------------------------------------------------- 
#
# test:mktempdir --
#
#      Create a temporary directory useful for storing transient data.
#
# Side effects:
#      A directory will be stored in /tmp/rerun.tests. It can be removed
#      by calling test:exit.
#
# ----------------------------------------------------------- 

function test:mktempdir {
    TMPDIR=$(mktemp -d /tmp/rerun.tests.XXXXXX) || test:die "failed creating temp directory"
    echo $TMPDIR
}

# ----------------------------------------------------------- 
#
# test:session --
#
#      Setup a rerun test environment and return a session.
#      A session is a location where transient test data can
#      be stored. The session contains a file with this 
#      metadata. 
#
# Results:
#
#      An array containing a structure described as such:
#           ( directory modules module command )
#
# Side effects:
#      A session directory will be created. It can be removed
#      by calling test:exit.
#
# ----------------------------------------------------------- 

function test:session {
    
    tempdir=$(test:mktempdir) || test:die "failed creating session directory"
    [ -d ${tempdir} ] || test:die "test directory not found: ${tempdir}"

    declare -a session=()
    session[0]=$tempdir
    session[1]=$1 ;# rerun
    session[2]=$2 ;# modules
    session[3]=$3 ;# module
    session[4]=$4 ;# command
    session[5]="" ;# options
    echo ${session[@]} | tee ${session[0]}/session

    return 0
}

# ----------------------------------------------------------- 
#
# test:context --
#
#      Prints and update the session context.
#      This command works in two rough usage modes:
#       1) context dump: print out the session context as an array.
#
#          test:context $session
#          
#       2) property lookup: print out a context property
#
#          test:context $session rerun|modules|command|option
#
#       3) property update: set a context property value
#
#         test:context $session rerun|modules|command|option [value]
#
# Side effects:
#      
#      
#
# ----------------------------------------------------------- 

function test:context {
    DIRECTORY=$1

    # Read the session data
    read data < $DIRECTORY/session
    session=( $data )
    [ ${#session[@]} -lt 4 ] && test:die "error reading session command context"

            if [ $# -eq 1 ] 
            then

	            echo ${session[@]}

            elif [ $# -eq 2 ]
            then
	            key=$2
	            case "$key" in 
	                rerun)   echo ${session[1]} ;;
	                modules) echo ${session[2]} ;;
	                module)  echo ${session[3]} ;;
	                command) echo ${session[4]} ;;
	                option)  echo ${session[5]} ;;
	            esac
	
            elif [ $# -eq 3 ]
            then
	            key=$2
	            value=$3
	            case "$key" in 
	                rerun)
	                    session[1]=$value ;;
	                modules)
	                    session[2]=$value ;;
	                module)
	                    session[3]=$value ;;
	                command)
	                    session[4]=$value ;;
	                option)
	                    session[5]=$value ;;
	            esac
	            echo ${session[@]} > ${session[0]}/session	
            fi
    }

#
# ----------------------------------------------------------- 
#
# test:fail --
#
#      End the test and clean up the session, and call exit.
#      
# Side effects:
#      Message printed to stderr.
#      Exit code returned as specified.
#
# ----------------------------------------------------------- 

function test:fail {
    [ ! $# -eq 2 ] && { 
	    test:die 'wrong # args: should be: test:fail directory msg'
    }

    DIRECTORY=$1
    MESSAGE=$2

    context=( $(test:context $DIRECTORY) )
    LEN=${#context[@]}
    command="${context[3]}:${context[4]} ${context[@]:5:$LEN}"

    test:exit $DIRECTORY 1 "fail: \"${MESSAGE}\", command: \"$command\""
}


# ----------------------------------------------------------- 
#
# test:setup --
#
#      Pre-execution function.
#
# Results:
#
# -----------------------------------------------------------

function test:setup {
    :
}

# ----------------------------------------------------------- 
#
# test:teardown --
#
#      Post-execution function.
#
# Results:
#
# -----------------------------------------------------------

function test:teardown {
    :
}

# ----------------------------------------------------------- 
#
# test:extract --
#
#      Extract benchmark data from the input file and 
#      store the extracted text data to the session.
#      
# Results:
#
#      The function prints the extract file location.
#
# Side effects:
#      The session directory will contain the benchmark text.
#
# ----------------------------------------------------------- 

function test:extract {
    [ ! $# -eq 2 ] && { 
	    test:die 'wrong # args: should be: test:extract storedir infile'
    }
        
    STORE_DIR=$1
    INFILE=$2

    [ -r "$INFILE" ] || test:die "input file not found: $INFILE"
    [ -d "$STORE_DIR" ] || test:die "directory not found: $STORE_DIR"
    #
    # Count number of lines from file delimiter
    #
    SIZE=$(awk '/^__BENCHMARK_TEXT__/ {print NR + 1; exit 0; }' $INFILE) || {
	    test:die "failed sizing benchmark text"
    }
    #
    # Read text from delimiter onward and write the text to outfile
    #
    tail -n+$SIZE $INFILE > $STORE_DIR/BENCHMARK_TEXT || {
	    test:die "failed extracting benchmark text"
    }
    #
    # Print the path to the extracted output file
    #
    echo $STORE_DIR/BENCHMARK_TEXT
}

#
# ----------------------------------------------------------- 
#
# test:exec --
#
#      Execute the command
#      
#      - directory: The session directory
#      - options: The command options
#      
# Results:
#
#      
#
# Side effects:
#      
#
# ----------------------------------------------------------- 

function test:exec {
    [ ! $# -eq 2 ] && { 
	    test:die 'wrong # args: should be: test:exec directory options'
    }

    DIRECTORY=$1

    declare -a session=()

    read data < $DIRECTORY/session;  # Read the session data
    session=( $data )
    [ ${#session[*]} -lt 4 ] && test:die "error reading session command context"

    if [ -n "$2" ]
    then
	    OPTIONS=$2
	    test:context $DIRECTORY option "$2"
    else
	    OPTIONS=${session[5]}
    fi
    RERUN=${session[1]} MODULES_DIR=${session[2]} MODULE=${session[3]} COMMAND=${session[4]}

    $RERUN -M $MODULES_DIR $MODULE:$COMMAND $OPTIONS 
    RETVAL=$?
    
    return $RETVAL
}

#
# ----------------------------------------------------------- 
#
# test:pass --
#
#      Assert the command will pass.
#      
#      Fully specified a context can be defined with the
#      following array:
#            ( directory command message )
#      - directory: The session directory
#      - options: The command options
#      
# Results:
#      0 - command succeeds
#      1 - command failed
#
# Side effects:
#    test:setup, test:teardown  
#
# ----------------------------------------------------------- 

function test:pass {
    [ "$#" -lt 1 ] && { 
	    test:die 'wrong # args: should be: test:pass directory command'
    }

    DIRECTORY=$1
    COMMAND=$2

    test:setup $DIRECTORY
    test:exec $DIRECTORY "$COMMAND" >/dev/null
    RETVAL=$?

    test:teardown $DIRECTORY

    if [ "$RETVAL" -eq 0 ]
    then
	    return 0
    else
	    test:log $DIRECTORY $MESSAGE
	    return 1
    fi
}

# ----------------------------------------------------------- 
#
# test:equals --
#
#      Execute the command and compare results to benchmark.
#
# Results:
#    0 - command output matches benchmark
#    1 - command output did not match benchmark
# -----------------------------------------------------------

function test:equals {
    [ ! $# -eq 3 ] && { 
	    test:die 'wrong # args: should be: test:equals directory command benchmark'
    }
    DIRECTORY=$1
    COMMAND=$2

    #
    # Call the test setup
    #
    test:setup $DIRECTORY

    #
    # Execute the command
    #
    test:exec $DIRECTORY "$COMMAND" | tee $DIRECTORY/out || test:die "command execution failure"

    if [ -f "$3" ] 
    then
	    BENCHMARK=$3
    else
	    echo "$3" > $DIRECTORY/benchmark
	    BENCHMARK=$DIRECTORY/benchmark
    fi

    #
    # Compare the output with the benchmark text
    #
    diff $BENCHMARK  $DIRECTORY/out >&2
    RETVAL=$?

    #
    # Tear down the test setup
    #
    test:teardown $DIRECTORY

    #
    # Return the comparison status
    #
    return $RETVAL
}
