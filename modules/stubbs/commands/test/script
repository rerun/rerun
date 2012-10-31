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
#/ usage: stubbs:test --module|-m <> [--plan|-p <*>] [--logs <>] 

# Source common function library
. $RERUN_MODULE_DIR/lib/functions.sh || { echo >&2 "failed loading function library" ; exit 1 ; }


rerun_init

# Get the options
while [ "$#" -gt 0 ]; do
    OPT="$1"
    case "$OPT" in
        # options without arguments
	# options with arguments
	    -m|--module)
	        rerun_option_check "$#" "$1"
	        MODULE="$2"
	        shift
	        ;;
	    -p|--plan)
	        rerun_option_check "$#" "$1"
	        PLAN="${2}-*"
	        shift
	        ;;

    # unknown option
	    -?)
	        rerun_option_usage
            exit 2
	        ;;
	  # end of options, just arguments left
	    *)
	        break
    esac
    shift
done

[ -z "$MODULE" ] &&  { rerun_option_error "missing required option: --module"; }
[ -z "$PLAN" ] && PLAN="*"

if [ ! -d "$RERUN_MODULES/$MODULE/tests" ]
then
    # there should always be at least one test!
    rerun_die "No tests" 
fi

echo "========================================================="
echo " TESTING MODULE: $MODULE "
echo "========================================================="
(
    # Resolve relative path to rerun
    export RERUN=$(rerun_absolutePath $RERUN)
    export ROUNDUP=$(rerun_absolutePath $RERUN_MODULE_DIR/lib/roundup)

    # Set modules path
    export RERUN_MODULES=$RERUN_MODULES

    # Roundup likes to run relative
    cd $RERUN_MODULES/$MODULE/tests

    # Run the tests
    #
    $ROUNDUP $PLAN-test.sh
) 

# Done

