# Shell functions for the stubbs module.
#/ usage: source RERUN_MODULE_DIR/lib/functions.sh command
#

# Read rerun's public functions
. "$RERUN" || {
    echo >&2 "ERROR: Failed sourcing rerun function library: \"$RERUN\""
    return 1
}

# Check usage. Argument should be command name.
[[ $# = 1 ]] || rerun_option_usage "usage: $0 <command-name>"

# Source the option parser script.

if [[ -r "$RERUN_MODULE_DIR/commands/$1/options.sh" ]] 
then
    . "$RERUN_MODULE_DIR/commands/$1/options.sh" || {
        rerun_die "Failed loading options parser."
    }
fi

# - - -
# Your functions declared here.
# - - -

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
	    rerun_die "usage: ${FUNCNAME} directory"
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
        [[ "$short" = "${opt_short:-}" ]] && with_short=( ${with_short[*]:-} $option )
    done
    echo ${with_short[*]:-}
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
            set +u; source  $moddir/options/${opt}/metadata; set -u
            if [[ -n "${SHORT}" ]] 
            then  argstring=$(printf ' --%s|-%s' "${NAME}" "${SHORT}")
            else  argstring=$(printf " --%s" "${NAME}" )
            fi		  

            if [[ "true" == "${ARGUMENTS}" ]]
            then
                # Lookup the default but set expand=false to not evalute env variable.
                DEFAULT=$(rerun_property_get "$moddir/options/${opt}" DEFAULT false)
                argstring=$(printf "%s <%s>" "$argstring" "${DEFAULT}")
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
        s^#/ command: .*^#/ command: $module:$command: \"$description\"^
        s^#/ option-variables: .*^#/ option-variables: $variables^
        s^#/ usage: .*^#/ usage: rerun $module:$command $usage^
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

#
# - - -
#
generate_command_script() {
  local -r cmd=$1 module=$2 description=$3 vars=$4 overwrite=$5 cmd_script=$6
  # Generate a boiler plate implementation
  if [[ ! -f "${cmd_script}" ]] || [[ "${overwrite:-}" == "true" ]]; then
    cat - | sed -e "s/@COMMAND@/$cmd/g" \
        -e "s/@MODULE@/$module/g" \
        -e "s^@DESCRIPTION@^$description^g" \
        -e "s/@VARIABLES@/$vars/g" > "$cmd_script"
    chmod +x "${cmd_script}" || rerun_die "Failed setting execute bit on command script."        
    rerun_log info "Wrote command script: $cmd_script"
  fi
}

generate_command_metadata() {
  local -r cmd=$1 description=$2 generate_help=$3 overwrite=$4 metadata=$5
  if [[ ! -f "$metadata" || "${overwrite:-}" == "true" ]]; then
    # Generate command metadata
    cat <<EOF > "$metadata" || rerun_die "Failed creating command metadata."
# command metadata
# generated by stubbs:add-command
# $(date)
NAME=$cmd
DESCRIPTION="$description"
OPTIONS=
GENERATE_HELP="$generate_help"
EOF
  fi
  rerun_log info "Wrote command metadata: $RERUN_MODULE_HOME_DIR/commands/$cmd/metadata"  
}


generate_options_parser() {
  local -r cmd=$1 module=$2 overwrite=$3 stub=$4 options_parser_script=$5
  local OPTIONS_GENERATOR OPTIONS_SCRIPT
  if [[ ! -f "$options_parser_script" || "${OVERWRITE:-}" == "true" ]]; then
    .  "$stub/metadata" || {
      rerun_die "error reading $RERUN_MODULE_DIR/lib/stub/bash/metadata"
    }
    [[ -z "${OPTIONS_GENERATOR:-}" ]] && {
      rerun_die "required metadata not found: OPTIONS_GENERATOR"
    }
    [[ -z "${OPTIONS_SCRIPT:-}" ]] && {
      rerun_die "required metadata not found: OPTIONS_SCRIPT"
    }
    "$stub/$OPTIONS_GENERATOR" \
      "$(dirname "$RERUN_MODULE_HOME_DIR")" "$module" "$cmd" > "$options_parser_script" || {
      rerun_die "Failed generating options parser."
    }
    rerun_log info "Wrote options parser: $options_parser_script"
  fi
}


generate_command_test() {
    echo "DEBUG: generate_command_test \$@ = $@"
  local -r cmd=$1 module=$2 overwrite=$3 test_dir=$4 testsuite=${5:?testsuite?} test_functions=${6:?function-template}


  mkdir -p "$test_dir" || rerun_die "failed creating tests directory"

  if [[ ! -f "$testsuite" || "${overwrite:-}" == "true" ]]; then
    cat - | sed -e "s/@MODULE@/$module/g" \
        -e "s/@COMMAND@/$cmd/g" \
        -e "s;@RERUN@;${RERUN};g" \
        -e "s;@RERUN_MODULES@;${RERUN_MODULES};g" \
            > "$test_dir/$testsuite" || rerun_die "Failed to generate test script from template."
    rerun_log info "Wrote test script: $test_dir/$testsuite"
  fi

  if [[ ! -f "$test_functions" || "${overwrite:-}" == "true" ]]; then
      sed -e "s/@MODULE@/$module/g" \
         "$test_functions" > "$test_dir/functions.sh" || rerun_die "Failed generating test functions library."
      rerun_log info "Wrote test function library: $test_dir/functions.sh"
  fi
}


generate_module_structure() {
    local -r module_dir=$1
    mkdir -p "$module_dir" || rerun_die "Failed creating module structure."
    # Create commands/ and lib/ subdirectories
    mkdir -p "$module_dir"/{commands,lib} || rerun_die "Failed creating module structure."
}
generate_module_metadata() {
    local -r module_dir=$1 module=$2 description=$3 command_shell=$4
# Generate a profile for metadata
cat <<EOF > "$module_dir/metadata" || rerun_die "Failed generating metadata."
# generated by stubbs:add-module
# $(date)
NAME=$module
DESCRIPTION="$description"
SHELL="${command_shell}"
VERSION=1.0.0
REQUIRES=
EXTERNALS=
LICENSE=
EOF
}

# Give it the beginnings of a function library.
generate_module_library() {
    local -r module_dir=$1 module=$2 description=$3 template=$4
    local -r functions="$module_dir/lib/$(basename "$template")" 
    [[ ! -d "$module_dir/lib" ]] && rerun_die "Lib dir does not exist: $module_dir/lib"
    sed -e "s/@MODULE@/$module/g" \
        -e "s^@DESCRIPTION@^$description^g" \
        -e "s,@SHELL@,$COMMAND_SHELL,g" > "$functions" < "$template"
}





