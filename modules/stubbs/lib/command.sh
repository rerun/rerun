error() {
    echo "ERROR: $* " ;
    exit 1;
}

# print USAGE and exit
syntax_error() {
    echo "$USAGE" >&2
    echo "$SYNTAX $*" >&2
    exit 2
}

# check option has its argument
arg_syntax_check() {
    [ "$1" -lt 2 ] && syntax_error
}



# Bootstrap a command handler
rerun_init() {
    # Shell modules reside in current directory, by default. 
    homedir=$(dirname .)
    # Use env var property if it exists otherwise set it to default.
    [ -n "$RERUN_MODULES" ] || {
	RERUN_MODULES=$homedir/modules
    }
}

rerun_modules() {
    names=
    for f in `echo $1/*/metadata`; do
	mod_name=$(basename $(dirname $(dirname $f)))
	names="$names $mod_name"
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

rerun_optionDefault() {
    awk -F= '/DEFAULT/ {print $2}' $1/$2/commands/$3/$opt.option
}

rerun_optionparser() {
    oU=$(echo $1 | tr "[:lower:]" "[:upper:]")
    printf " -%s) arg_syntax_check \$# ; %s=\$2 ; shift ;;\n" "$1" "$oU"
}

rerun_optionsparser() {
    options=
    for o in $(rerun_options $1 $2 $3); do
	stanza=$(printf "%s\n" $(rerun_optionparser $o))
	 options="$options $stanza"
    done
    echo $options
}