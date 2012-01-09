#
# common rerun functions
#

#
# colorizing functions
#
# bold - bold the given text
bold() { echo -e "\033[1m$*\033[0m" ; reset ; }
# reset the terminal
reset () { tput sgr0 ; }

# print error message and exit
rerun_die() {
	[[ "$RERUN_COLOR" == "true" ]] && bold "ERROR: $*" >&2 || echo "ERROR: $*" >&2
	exit 1
}

# print USAGE and exit
rerun_option_error() {
    [ -z "$USAGE"  ] && echo "$USAGE" >&2
    [ -z "$SYNTAX" ] && echo "$SYNTAX $*" >&2
    exit 2
}

# check option has its argument
rerun_option_check() {
    [ "$1" -lt 2 ] && rerun_option_error
}

# Bootstrap a command handler
rerun_init() {
    # Shell modules reside in current directory, by default. 
    homedir=$(dirname .)
    # Use env var property if it exists otherwise set it to default.
    [ -n "$RERUN_MODULES" ] || RERUN_MODULES=$homedir/modules    
}

rerun_modules() {
    names=
    for f in `echo $1/*/metadata`; do
	[ -f $f ] && {
		mod_name=$(basename $(dirname $f))
		names="$names $mod_name"
	}
    done
    echo $names
}

rerun_commands() {
    commands=
    for c in `echo $1/$2/commands/*/default.sh`; do
	[ -f $c ] && {
	    cmd_name=$(basename $(dirname $c))
	    commands="$commands $cmd_name"
	}
    done
    echo $commands
}

rerun_options() {
    options=
    for o in `echo $1/$2/commands/$3/*.option`; do
	[ -f $o ] && {
	    opt_def=$(basename $o)
	    opt_name=${opt_def%.option}
	    options="$options $opt_name"
	}
    done
    echo $options
}

rerun_optionArguments() {
	[ -f $1/$2/commands/$3/$4.option ] && {
		awk -F= '/ARGUMENTS/ {print $2}' $1/$2/commands/$3/$4.option
	}
}

rerun_optionDefault() {
	[ -f $1/$2/commands/$3/$4.option ] && {
    	awk -F= '/DEFAULT/ {print $2}' $1/$2/commands/$3/$4.option
	}
}

rerun_optionShort() {
	[ -f $1/$2/commands/$3/$4.option ] && {
    	awk -F= '/SHORT/ {print $2}' $1/$2/commands/$3/$4.option
	}
}

rerun_optionRequired() {
	[ -f $1/$2/commands/$3/$4.option ] && {
    	awk -F= '/REQUIRED/ {print $2}' $1/$2/commands/$3/$4.option
	}
}

rerun_tests() {
	modules=$1
	module=$2
    tests=
    for t in $modules/$module/tests/commands/*/*.sh
	do
	[ -f $t ] && {
	    test_name=$(basename $t)
	    tests="$tests $test_name"
	}
    done
    echo $tests
}

rerun_testDescription() {
	[ -f $1/$2/tests/commands/$3/metadata ] && {
		awk -F= '/DESCRIPTION/ {print $2}' $1/$2/tests/commands/$3/metadata
	}
}
