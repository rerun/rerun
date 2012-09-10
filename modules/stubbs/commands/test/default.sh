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
source $RERUN_MODULES/stubbs/lib/functions.sh || { echo "failed loading function library" ; exit 1 ; }


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
	        COMMAND="${2}-*"
	        shift
	        ;;

    # unknown option
	    -?)
	        echo "$USAGE" >&2 ; exit 2 ;
	        ;;
	  # end of options, just arguments left
	    *)
	        break
    esac
    shift
done

[ -z "$MODULE" ] &&  { echo "missing required option: --module" >&2; exit 2 ; }
[ -z "$COMMAND" ] && COMMAND="*"

if [ ! -d "$RERUN_MODULES/$MODULE/tests" ]
then
    rerun_die "No tests"
fi

echo "========================================================="
echo " $MODULE $COMMAND"
echo "========================================================="
(
    # Resolve relative path to rerun
    export RERUN=$(rerun_absolutePath $RERUN)
    export ROUNDUP=$(rerun_absolutePath $RERUN_MODULES/stubbs/lib/roundup)

    # Set modules path
    export RERUN_MODULES=$RERUN_MODULES

    # Roundup likes to run relative
    cd $RERUN_MODULES/$MODULE/tests

    # Run the tests
    #
   $ROUNDUP $COMMAND-test.sh
) 

# Done

