#
# rerun command completion script.
#  **rerun** is a simple, small modular automation
#  framework based on Bash, the POSIX shell.
#

# Enable RERUN_COLOR
export RERUN_COLOR=true

# Installation
# -------------
#
# #. Download or git clone from [rerun](http://github.com/rerun/rerun).
# #. Source this file from your .bashrc.
#
# Usage
# -----
#
# The contained completion support provides for:
#
# * Module listing:
#       `rerun [tab][tab]`
# * Command listing for specified module:
#       `rerun module:[tab][tab]`
# * Option listing for specified module:command:
#       `rerun module: command[tab][tab]`
# * Arguments for specified option:
#       `rerun module: command --file[tab][tab]`
#
# @author: <a href="mailto:alexhonor@yahoo.com">alexhonor@yahoo.com</a>

# Default system install path for the lib dir.
DEFAULT_LIBDIR="/usr/lib"

if [[ -z "${RERUN_MODULES:-}" ]]
then
    # check if it is a system install
    if [[ -d ${DEFAULT_LIBDIR}/rerun/modules ]]
    then
      export RERUN_MODULES="${DEFAULT_LIBDIR}/rerun/modules";  
    else      
      export RERUN_MODULES=$(pwd)/modules; # Default it the current working directory.
    fi
fi

#
# Shell functions to support the command completion
#

# list:member - check if item is contained in list
list:member()
{
    local  item="$1" list="$2"
    for member in $(eval echo $list)
    do
	    [ "${item}" = "${member}" ] && return 0
    done
    return 1	
}

# list:subtract - subtract list2 members from list1
list:subtract() 
{
    local list1="$1" list2="$2" retlist=""
    for item in $(eval echo $list1)
    do
	    list:member $item "$list2" || retlist="$retlist $item"
    done
    echo $retlist    
}

# path_components - return a newline-separated list of components in a colon-separated path
path_components()
{
    local pathvar=$1
    echo "$pathvar" | sed ':loop
    {h
    s/:.*//
    p
    g
    s/[^:]*://
    t loop
    d
    }'
}

# rerun:modules - list all rerun modules
rerun:modules()
{
    local modules=""
    for dir in $(path_components $RERUN_MODULES)
    do
        for mod in $dir/*
        do 
            if [[ -f "$mod/metadata" ]]
            then
                list:member $(basename $mod) $modules || modules="$modules $(basename $mod)"
            fi
        done
    done
    echo $modules
}

# get home dir of the module
rerun:module_home_dir()
{
   
    local module=$1
    local home_dir=""
    for dir in $(path_components $RERUN_MODULES)
    do
        if [[ -f "$dir/$module/metadata" ]]
        then
            home_dir=$dir/$module
            break
        fi
    done
    echo $home_dir
}

# rerun:module:list - list all the commands for the module
rerun:module:commands()
{
    local module=$1 commands=""
    local module_home_dir=$(rerun:module_home_dir $module)
    for hdlr in $module_home_dir/commands/*/metadata; do
	[ -f $hdlr ] && {
	    cmd_name=$(basename $(dirname $hdlr))
	    commands="$commands $cmd_name"	
	}
    done    
    echo $commands
}

# rerun:command:options - List all the registered options for the command
rerun:command:options() 
{
    local module=$1 command=$2 prefix=$3 options=""
    local module_home_dir=$(rerun:module_home_dir $module)
    for opt in $(. $module_home_dir/commands/$command/metadata; echo $OPTIONS)
    do
        options="$options ${prefix}${opt}"
    done
    
    echo $options
}

# rerun:option:default - get the default for the specified option
rerun:option:default()
{
    local module=$1 command=$2 opt=$3 
    local module_home_dir=$(rerun:module_home_dir $module)
    local opt_metadata=$module_home_dir/options/${opt##*-}/metadata
    [ -f "$opt_metadata" ] && {
        awk -F= '/^DEFAULT/ {print $2}' "$opt_metadata"
	}
}

# rerun:option:has-argument - check if option takes an argument
rerun:option:has-argument()
{
    local module=$1 command=$2 opt=$3
    local module_home_dir=$(rerun:module_home_dir $module)
    local opt_metadata=$module_home_dir/options/${opt##*-}/metadata
    [ -f "$opt_metadata" ] && {
        args=$(awk -F= '/^ARGUMENTS/ {print $2}' $opt_metadata )
        [ "$args" = "true" ] && return 0 
    }
    return 1
}

# rerun:options:remaining - list remaining options
rerun:options:remaining() 
{
    local argline=$1 options=$2 used="" 
    for arg in $argline; do
        [[ "$arg" == -* ]] && used="$used ${arg}"
    done
    list:subtract "$options" "$used"
}

rerun:parse:module() 
{
    local cmdline=$@
    local module
    local regex="[ ]+--module[ ]([[:alnum:]]+)[ ]*"
    if [[ "$cmdline" =~ $regex ]]
    then
        module=${BASH_REMATCH[1]}
    fi
    echo $module
}

#
# _rerun - program completion for the `rerun` command.
#
_rerun() {
    [ -z "${RERUN_MODULES}" -o ! \( -d "$(echo $RERUN_MODULES|cut -d: -f1)" \) ] && { 
        return 0 ; 
    }
    local cur prev cntx_module cntx_command cntx_options options
    local module_home_dir
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
 
    eval set $COMP_LINE
    shift; # shift once to drop the "rerun" from the argument string

    # Define regex pattern to parse command line input
    #   module:command --optionA arg --optionB arg ...
	regex='([^:]+)([:]?[ ]?)([A-Za-z0-9_-]*)([ ]*)(.*)'
	if [[ "$@" =~ $regex ]]
	then
        # module context
        module_home_dir=$(rerun:module_home_dir "${BASH_REMATCH[1]}")
        [ -n "$module_home_dir" ] && cntx_module=${BASH_REMATCH[1]};
        [ "${BASH_REMATCH[2]}" == ': ' ] && shift ;# eat the extra space char
        # command context
	    [ -d "$module_home_dir/commands/${BASH_REMATCH[3]/ /}" ] && {
	    	cntx_command=${BASH_REMATCH[3]/ /}
        }
        # BASH_REMATCH[4] contains the whitespace between command and options
        # option context
        cntx_options=${BASH_REMATCH[5]};  
	fi

    # Shift over to the command options
    shift;

    # Complete commands given the user shell input. 

    # Just the rerun command was typed. List modules
    [ -z "$cntx_module" ]  && {
        local modules=$(rerun:modules $RERUN_MODULES)
        COMPREPLY=( $(compgen -W "$modules" -S ':' -o nospace -- ${cur}) )
        return 0
    }    
    
    # Module specified: List module's commands
    [ -n "$cntx_module" -a -z "$cntx_command" ] && {
        local commands=$(rerun:module:commands ${cntx_module})
        COMPREPLY=( $(compgen -W "$commands" -- ${cur}) )
        return 0
    }
    
    # Command specified. List command's options
    options=$(rerun:command:options ${cntx_module} ${cntx_command} "--")
    if [ -n "$cntx_command" -a -z "$cntx_options"  ]; then
        COMPREPLY=( $(compgen -W "$options" -- "${cur}") )
        return 0 
    fi

    # Option(s) specified. Show possible arguments or remaining option choices.
    if [ -n "$cntx_options"  ]; then
        if [[ $prev == -* ]]; then
            # check if current option takes an argument ...
            if rerun:option:has-argument ${cntx_module} ${cntx_command} ${prev}; then
                # ... and has a default value
                local default=$(rerun:option:default ${cntx_module} ${cntx_command} ${prev})
                if [ -n "$default" ]; then
                    # print the default value
                    COMPREPLY=( $(compgen -W "$default" -- ${cur}) )
                    return 0
                else
                    # ... or wants option specific completion
                    case "$prev" in
                        --file*|--out*|--xml|--template)
                            # file completion
                	        COMPREPLY=( $(compgen -o filenames -A file -- ${cur}) )  ;;
                        --*dir*|--logs*)
                            # directory completion
                	        COMPREPLY=( $(compgen -o dirnames -A directory -- ${cur}) ) ;;
                        --module)
                            # module completion
                            modules=$(rerun:modules)

                            COMPREPLY=( $(compgen -W "$modules" -- ${cur}) ) ;;
                        --command)
                            # command completion
                            module=$(rerun:parse:module ${COMP_WORDS[*]} )
                            [ -n "$module" ] && {
                                commands=$(rerun:module:commands ${module})
                                COMPREPLY=( $(compgen -W "$commands" -- ${cur}) ) 
                            }
                            ;;
                    esac
                    return 0
            	fi
            fi
        else
        	# Show the remaining/unused option choices
            remaining=$(rerun:options:remaining "$cntx_options" "$options")
            COMPREPLY=( $(compgen -W "$remaining" -- ${cur}) )

	    fi
	    return 0
    fi
}
# register the _rerun completion function
complete -F _rerun rerun

#
# This is Free Software distributed under the Apache 2 license.
:
