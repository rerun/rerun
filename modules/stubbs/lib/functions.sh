#
# Utiltiy functions used by *stubbs* commands.
#

#
# Stubbs functions build on the rerun functions.
#
[ ! -f "$RERUN" ] && {
    echo >&2 "ERROR: \$RERUN environment variable not set to rerun"
    exit 1
}

. $RERUN || { 
    echo >&2 "ERROR: Failed sourcing functions from rerun: $RERUN" 
    exit 1 
}


# _rerun_interpreters_ - List the interpreters by name.
#
#     rerun_interpreters directory 
#
# Arguments:
#
# * directory:     Directory containing interpreter libraries.
#
# Notes: 
#
# * Returns a list of space separated interpreter names.
# 
stubbs_interpreters() {
    [[ ! $# -eq 1 ]] && { 
	    rerun_die 'wrong # args: should be: stubbs_interpreters directory'
    }
    [[ ! -d $1 ]] && rerun_die "directory not found: $1"
    local -a interps
    for f in `echo $1/*/metadata`
    do
       if [[ -f $f ]]
        then 
            local interp="$(basename $(dirname $f))" 
            [[ -z "${interps:-}" ]] && interps=( $interp ) || interps=( ${interps[*]} $interp )
        fi 
    done
    echo ${interps[*]}
}


#
# - - -
#

# _stubbs_option_property_ - Get value for specified option property.
#
#     stubbs_option_property directory option property
#
# Arguments:
#
# * directory: the module directory
# * option: option name
# * property: the metadata property
#
stubbs_option_property() {
    echo "$(rerun_property_get "$1/options/$2" $3)"
}

#
# - - -
#

# _stubbs_command_property_ - Get value for specified command property.
#
#     stubbs_command_property directory property
#
# Arguments:
#
# * directory: the module directory
# * command: the command name
# * property: the metadata property
#
stubbs_command_property() {
    echo $(rerun_property_get "$1/commands/$2" $3)
}

#
# - - -
#

#
# _stubbs_options_matching_ - List options matching property.
#
#     stubbs_options_matching directory command PROPERTY
#      
# Arguments:
#
# * directory: the module directory
# * command: the command name
# * property: the metadata property
#
#
stubbs_options_matching() {
    [[ ! $# > 2 ]] && { 
        echo >&2 "usage: stubbs_option_matching directory command" ; 
        return 1 ; 
    }
    local moddir=$1 command=$2
    shift; shift;
    local predicates=( $@ )

    local options=()
    for option in $(rerun_options $(dirname $moddir) $module $command)
    do
        for predicate in ${predicates[*]}
        do
            property=${predicate%=*} pattern=${predicate#*=}            
            value=$(stubbs_option_property $moddir $option $property)
            if [[ "$value" =~ $pattern ]] 
            then
                ! rerun_list_contains $option ${options[*]} ]] && options=( ${options[*]} $option )
            fi
        done
    done
    echo "${options[*]}"
}

#
# - - -
#

# _stubbs_option_variable_ - Upper case the string and change dashes to underscores.
#
#     stubbs_option_variable string
#
# Arguments:
#
# * string: string to translate
#
stubbs_option_variable() { 
    echo "$1" | tr '[:lower:]' '[:upper:]' | tr  '-' '_' ; 
}

#
# - - -
#

# _stubbs_option_variables_ - Lists an option's variable names.
#
#     stubbs_option_variables directory module command
#
# Arguments:
# 
# * directory: Module directory
# * command: Command name
#
stubbs_option_variables() {
    [[ ! $# = 2 ]] && { 
        echo >&2 "usage: stubbs_option_variables <moddir> <command>" 
        return 1 ; 
    }
    local moddir=$1 command=$2

    local variables=()
    for option in $(rerun_options $(dirname $moddir) $(basename $moddir) $command)
    do
        variables=( ${variables[*]} $(stubbs_option_variable $option) )
    done
    echo ${variables[*]}
}

#
# - - -
#

# _stubbs_options_with_short_ - List all options that have short.
#
#     stubbs_options_with_short directory module command
#
# Arguments:
# 
# * directory: Module directory
#
stubbs_options_with_short() {
    [[ ! $# = 2 ]] && { 
        echo >&2 "usage: stubbs_options_with_short <moddir> <short>" 
        return 1 ; 
    }
    local -r moddir=$1 short=$2
    local -a with_short=()
    for option in $(rerun_module_options $(dirname $moddir) $(basename $moddir))
    do
        local opt_short=$(stubbs_option_property $moddir $option SHORT)
        [[ "$short" = "$opt_short" ]] && with_short=( ${with_short[*]} $option )
    done
    echo ${with_short[*]}
}

#
# - - -
#

# _stubbs_option_commands_ - Lists the commands assigned to option
#
#     stubbs_option_commands directory option
#
# Arguments:
# 
# * directory: the module directory
# * option: the option name
#
stubbs_option_commands() {
    [[ ! $# = 2 ]] && { 
        echo >&2 "usage: stubbs_option_commands <moddir> <option>" 
        return 1 ; 
    }
    moddir=$1 option=$2
    commands=()
    for cmd_dir in $moddir/commands/*
    do
        local -a command_options=( $(rerun_property_get $cmd_dir OPTIONS) )
        [[ -z "${command_options}" ]] && continue; # no option assignments.

        rerun_list_contains "$option" "${command_options[@]}" && {
            commands=( ${commands[@]} $(basename $cmd_dir) )
        }
    done
    echo "${commands[*]}"
}

#
# - - -
#


#
# _stubbs_command_usage_ - print command usage string
#
#     stubbs_command_usage module_dir command
#
# Arguments:
#
# * module_dir: the module directory
# * command: command name
#
stubbs_command_usage() {
    [[ ! $# = 2 ]] && { 
        echo >&2 "usage: stubbs_command_usage module_dir command" ; 
        return 1 ; 
    }
    local moddir=$1 command=$2
    local module=$(basename $moddir)
    for opt in $(rerun_options $(dirname $moddir) $module $command)
    do
        [[ -f $moddir/options/${opt}/metadata ]] || continue
        (
            local usage=
            source  $moddir/options/${opt}/metadata

            if [[ -n "${SHORT}" ]] 
            then  argstring=$(printf ' --%s|-%s' "${NAME}" "${SHORT}")
            else  argstring=$(printf " --%s" "${NAME}" )
            fi		  

            if [[ "true" == "${ARGUMENTS}" ]]
            then   argstring=$(printf "%s <%s>" "$argstring" "${DEFAULT}")
            fi

            if [[ "true" != "${REQUIRED}" ]]
            then  usage=$(printf "[%s]" "${argstring}") 
            else  usage=$(printf "%s" "${argstring}")
            fi

            printf "%s " "$usage"
        )
    done
}

#
# - - -
#

# _stubbs_script_header_ - Prints the header for a command script
#
#     stubbs_script_header directory command
#
# Arguments:
# 
# * directory: module directory 
# * command: command name
#
stubbs_script_header() {
    [[ ! $# = 2 ]] && { 
        echo >&2 "usage: stubbs_script_header <moddir> <command>" 
        return 1 ; 
    }
    local moddir=$1 command=$2     

    local module=$(basename $moddir)
    local script_name=$(rerun_property_get $moddir RERUN_COMMAND_SCRIPT)
    local command_script=$moddir/commands/$command/${script_name:-script}
    [[ ! -f "$command_script" ]] && {
        rerun_die "command script not found: $command_script"
    }

    local description=$(stubbs_command_property $moddir $command DESCRIPTION)
    local variables=$(stubbs_option_variables $moddir $command) 
    local usage=$(stubbs_command_usage $moddir $command) 

    sed "
        s,#/ command: .*,#/ command: $module:$command: \"$description\",
        s,#/ option-variables: .*,#/ option-variables: $variables,
        s,#/ usage: .*,#/ usage: rerun $module:$command $usage,
        " $command_script 
    # Generate output to stdout.
}

#
# - - -
#

# _stubbs_command_options_write_ - Writes value for OPTIONS property
#
#     stubbs_command_options_write directory module command options
#
# Arguments: 
#
# * moddir: module directory
# * command: command name
# * options: Space separated list of option names
#
stubbs_command_options_write() {
    [[ ! $# = 3 ]] && { 
        echo >&2 "usage: rerun_command_options_write <moddir> <command> <options>" 
        return 1 ; 
    }
    local moddir=$1 command=$2 options=$3
    local module=$(basename $moddir)

    local command_metadata=$moddir/commands/$command/metadata
    [[ ! -f "$command_metadata" ]] && {
        rerun_die "command metadata not found: $command_metadata"
    }
    rerun_property_set $moddir/commands/$command OPTIONS="$options"
}

#
# - - -
#

# _stubbs_init_ - Bootstrap a stubbs command script
#
#     stubbs_init 
# 
# Shell modules reside in current directory, by default. 
# Use env var property if it exists otherwise set it to default.
stubbs_init() {
    homedir=$(dirname .)
    [[ -n "$RERUN_MODULES" ]] || RERUN_MODULES=$homedir/modules    
}
