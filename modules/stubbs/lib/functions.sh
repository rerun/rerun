#
# common rerun functions
#

. $RERUN || { echo >&2 "ERROR: Failed sourcing functions from rerun: $RERUN" ; exit 1 ; }

#
# Stubbs functions
#

# Bootstrap a command handler
rerun_init() {
    # Shell modules reside in current directory, by default. 
    homedir=$(dirname .)
    # Use env var property if it exists otherwise set it to default.
    [ -n "$RERUN_MODULES" ] || RERUN_MODULES=$homedir/modules    
}

rerun_optionArguments() {
    echo $(rerun_optionGetMetadataValue "$1/$2" $3 ARGUMENTS)
}

rerun_optionDefault() {
    echo $(rerun_optionGetMetadataValue "$1/$2" $3 DEFAULT)
}

rerun_optionShort() {
    echo $(rerun_optionGetMetadataValue "$1/$2" $3 SHORT)
}

rerun_optionRequired() {
    echo $(rerun_optionGetMetadataValue "$1/$2" $3 REQUIRED)
}
rerun_optionExported() {
    echo $(rerun_optionGetMetadataValue "$1/$2" $3 EXPORT)
}

rerun_commandDescription() {
    echo $(rerun_commandGetMetadataValue "$1/$2" $3 DESCRIPTION)
}

optionsWithDefaults() {
    local moddir=$1 module=$2 command=$3

    local optionsWithDefaults=""
    for opt in $(rerun_options $moddir $module $command); do
        default=$(rerun_optionDefault $moddir $module $opt)
        args=$(rerun_optionArguments $moddir $module $opt)
        [ -n "$default" -a "$args" == "true" ] && optionsWithDefaults="$optionsWithDefaults $opt"
    done
    echo $optionsWithDefaults
}

# list the options that are required
optionsRequired() {
    local moddir=$1 module=$2 command=$3
    local optionsRequired=""

    for opt in $(rerun_options $moddir $module $command); do
        required=$(rerun_optionRequired $moddir $module $opt)
        args=$(rerun_optionArguments $moddir $module $opt)
        [ "$required" == "true" -a "$args" = "true" ] && optionsRequired="$optionsRequired $opt"
    done
    echo $optionsRequired
}
# list the options that are exported as environment variables
optionsExported() {
    local moddir=$1 module=$2 command=$3
    local optionsExported=""

    for opt in $(rerun_options $moddir $module $command); do
        exported=$(rerun_optionExported $moddir $module $opt)
        [ "$exported" == "true" ] && optionsExported="$optionsExported $opt"
    done
    echo $optionsExported
}

# Upper case the string and change dashes to underscores.
trops() { echo "$1" | tr '[:lower:]' '[:upper:]' | tr  '-' '_' ; }

# Used to generate an entry inside options.sh
add_optionparser() {
	local optName=$1
    local optVarname=$(trops $optName)
	local ARGUMENTS=$(rerun_optionArguments $moddir $module $optName)
	local SHORT=$(rerun_optionShort $moddir $module $optName)
	if [ -n "${SHORT}" ] 
	then
		argstring=$(printf ' --%s|-%s' "${optName}"  "${SHORT}")
	else
		argstring=$(printf " --%s" "${optName}" )
    fi
	if [ "$ARGUMENTS" == "false" ]
	then
		printf " %s) %s=true ;;\n" "${argstring}" "$optVarname"
	else
    	printf " %s) rerun_option_check \$# ; %s=\$2 ; shift ;;\n" \
			"$argstring" "$optVarname"
	fi
}

add_commandUsage() {
    [ $# = 3 ] || { echo >&2 "usage add_commandUsage <moddir> <module> <command>" ; return 1 ; }
    local moddir=$1 module=$2 command=$3

    for opt in $(rerun_options $moddir $module $command); do
        [ -f $moddir/$module/options/${opt}/metadata ] || continue
        (
            local usage=
            source  $moddir/$module/options/${opt}/metadata
		    if [ -n "${SHORT}" ] 
		    then
			    argstring=$(printf ' --%s|-%s' "${NAME}" "${SHORT}")
		    else
			    argstring=$(printf " --%s" "${NAME}" )
		    fi		  
		    [ "true" == "${ARGUMENTS}" ] && {
			    argstring=$(printf "%s <%s>" "$argstring" "${DEFAULT}")
		    }
		    [ "true" != "${REQUIRED}" ] && {
			    usage=$(printf "[%s]" "${argstring}") 
		    } || {
			    usage=$(printf "%s" "${argstring}")
		    }
            printf "%s " "$usage"
        )
    done
}

list_optionVariables() {
    [ $# = 3 ] || { 
        echo >&2 "usage list_optionVariables <moddir> <module> <command>" 
        return 1 ; 
    }
    local moddir=$1 module=$2 command=$3
    local summary=
    for option in $(rerun_options $moddir $module $command); do
        summary="$summary $(trops $option)"
    done
    echo $summary
}

rerun_rewriteCommandScriptHeader() {
    [ $# = 3 ] || { 
        echo >&2 "usage rerun_rewriteCommandScriptHeader <moddir> <module> <command>" 
        return 1 ; 
    }
    local moddir=$1 module=$2 command=$3
    local desc=$(rerun_commandDescription $moddir $module $command)
    local variables=$(list_optionVariables $moddir $module $command) || rerun_die
    local usage=$(add_commandUsage $moddir $module $command) || rerun_die
    local RERUN_COMMAND_SCRIPT=$(rerun_moduleGetMetadataValue $moddir RERUN_COMMAND_SCRIPT)
    local commandScript=$moddir/$module/commands/$command/${RERUN_COMMAND_SCRIPT:-script}
    [ ! -f "$commandScript" ] && {
        rerun_die "command script not found: $commandScript"
    }
    sed "
        s,#/ command: .*,#/ command: $module:$command: \"$desc\",
        s,#/ variables: .*,#/ variables: $variables,
        s,#/ usage: .*,#/ usage: rerun $module:$command $usage,
        " $commandScript 
    # generated to stdout
}

rerun_rewriteCommandOptionsMetadata() {
    [ $# = 4 ] || { 
        echo >&2 "usage rerun_rewriteCommandOptionsMetadata <moddir> <module> <command> <options>" 
        return 1 ; 
    }
    local moddir=$1 module=$2 command=$3 options=$4
    local commandMetadata=$moddir/$module/commands/$command/metadata
    [ ! -f "$commandMetadata" ] && {
        rerun_die "command metadata not found: $commandMetadata"
    }
    grep -q "^OPTIONS=" $commandMetadata || {
        echo "OPTIONS=">>$commandMetadata
    }
    sed "s/OPTIONS=.*/OPTIONS=\"$options\"/" $commandMetadata
    # generated to stdout
}
