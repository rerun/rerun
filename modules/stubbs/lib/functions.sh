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


# _stubbs_metamodules_ - List the stubs by name.
#
#     stubbs_metamodules directory 
#
# Arguments:
#
# * directory:     Directory containing stub libraries.
#
# Notes: 
#
# * Returns a list of space separated stub names.
# 
stubbs_metamodules() {
    [[ ! $# -eq 1 ]] && { 
	    rerun_die 'usage: ${FUNCNAME} directory'
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
        echo >&2 "usage: ${FUNCNAME} directory command" ; 
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
    echo "${options[*]:-}"
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
        echo >&2 "usage: ${FUNCNAME} <moddir> <command>" 
        return 1 ; 
    }
    local moddir=$1 command=$2

    local -a variables=()
    for option in $(rerun_options $(dirname $moddir) $(basename $moddir) $command)
    do
        local variable=$(stubbs_option_variable $option)
        if [[ -z "${variables:-}" ]]
        then variables=( $variable )
        else variables=( ${variables[*]} ${variable} )
        fi
    done
    echo ${variables[*]:-}
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
        echo >&2 "usage: ${FUNCNAME} <moddir> <short>" 
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
        echo >&2 "usage: ${FUNCNAME} <moddir> <option>" 
        return 1 ; 
    }
    moddir=$1 option=$2
    commands=()
    for cmd_dir in $moddir/commands/*
    do
        [[ ! -d $cmd_dir ]] && continue; # not a directory
        local -a command_options=( $(rerun_property_get $cmd_dir OPTIONS) )
        [[ -z "${command_options:-}" ]] && continue; # no option assignments.

        rerun_list_contains "$option" "${command_options[@]}" && {
            commands=( ${commands[@]:-} $(basename $cmd_dir) )
        }
    done
    echo "${commands[*]:-}"
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
        echo >&2 "usage: ${FUNCNAME} module_dir command" ; 
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
        echo >&2 "usage: ${FUNCNAME} <moddir> <command>" 
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
        echo >&2 "usage: ${FUNCNAME} <moddir> <command> <options>" 
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

# _stubbs_file_replace_str_ - Replace a string of text in file.
#
#     stubbs_file_replace_str string replacewith file
#
# Arguments:
#
# * string: string to be matched.
# * replacewith: new string that replaces matched string.
# * file: file to operate on.
#
stubbs_file_replace_str() {
    [[ ! $# = 3 ]] && {
        echo >&2 "usage: ${FUNCNAME} string replacewith file"
        return 1 ;
    }
    local -r string=$1 replacewith=$2 file=$3
    if [[ ! -f "$file" ]]
    then rerun_die "File not found: $file"
    fi
    #printf ",s/$string/$replacewith/g\nw\nQ" | ed -s "$file" > /dev/null 2>&1
    sed "s^$string^$replacewith^g" $file > /tmp/file.$$
    mv /tmp/file.$$ $file
    return $?
}

#
# - - -
#

# _stubbs_module_clone_ - Clone a module from a template.
#
#     stubbs_module_clone moduledir templatedir
#
# Arguments:
#
# * moduledir: module directory for clone
# * templatedir: template directory
#
stubbs_module_clone() {
    [[ ! $# = 2 ]] && {
        echo >&2 "usage: ${FUNCNAME} moduledir templatedir"
        return 1 ;
    }
    local -r moduledir=$1 templatedir=$2
    [[ ! -d "$moduledir" ]] && rerun_die "Directory not found: $moduledir"
    [[ ! -d "$templatedir" ]] && rerun_die "Directory not found: $templatedir"

    local -r module_name=$(rerun_property_get $moduledir NAME)
    local -r module_desc=$(rerun_property_get $moduledir DESCRIPTION)
    local -r template_name=$(rerun_property_get $templatedir NAME)

    # Copy the template directory content to the new module directory
    cp -r $templatedir/* $moduledir/

    # Update the metadata in the clone.
    rerun_property_set $moduledir NAME=$module_name
    rerun_property_set $moduledir DESCRIPTION="$module_desc"

    # Find all the command scripts.
    local -a scripts=( $(find $moduledir/commands -type f -name script -o -name options.sh) )
    # Find all the test scripts.
    local -a tests=( $(find $moduledir/tests -type f -name \*.sh) )
    # List of matching files to be processed.
    local -a files=( ${scripts[*]:-} ${tests[*]:-} )

    # Process all the matching files, replacing template module
    # name using the clone's instead.
    #
    for file in ${files[*]:-}
    do
        grep "$template_name" $file >/dev/null && {
            stubbs_file_replace_str "$template_name" "$module_name" "$file"
        }
    done
    return 0
}
