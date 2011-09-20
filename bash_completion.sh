#
# BASH shell tab completion for RERUN
#
# Source this file from your login shell. 
#
# @author: <a href="mailto:alex@dtosolutions.com">alex@dtosolutions.com</a>

[ -n "${RERUN_MODULES}" -a -d "${RERUN_MODULES}" ] || {
    export RERUN_MODULES=$(pwd)
}

# list all the child directory names in specified parent 
_listdirnames()
{
    local dirs dir
    [ -d "$1" ] && dir=$1 || { return 1 ; }
    for d in $(echo ${dir}/*) 
    do 
	[ -d "$d" ] && dirs="$dirs $(basename $d)"
    done
    echo $dirs
}

# check if item is in the list
_lexists()
{
    local  item="$1" list="$2"
    for e in $(eval echo $list)
    do
	[ "${item}" = "${e}" ] && return 0
    done
    return 1	
}
# remove the item from the list
_lremove() 
{
    local list item retlist
    list=$2 item=$1 retlist=""
    for e in $(eval echo $list)
    do
	[ "$e" = "$item" ] || retlist="$retlist $e"
    done
    echo $retlist
}
# subtract the items in list2 from list1
_lsubtract() 
{
    local list1="$1" list2="$2" retlist=""
    for item in $(eval echo $list1)
    do
	_lexists $item "$list2" || retlist="$retlist $item"
    done
    echo $retlist    
}
# list all the commands for the module
_rerunListCommands()
{
    local  modulesdir module found
    modulesdir=$1 module=$2 found="" 
    for hdlr in $modulesdir/$module/commands/*/default.sh; do
	[ -f $hdlr ] && {
	    cmd_name=$(basename $(dirname $hdlr))
	    found="$found $cmd_name"	
	}
    done    
    echo $found
}

# List all the registered options for the command
_rerunListOpts() 
{
    local modulesdir module command options founddir
    modulesdir=$1 module=$2 command=$3 options="" founddir=""

    for opt_md in $modulesdir/$module/commands/$command/*.option; do
	opt=$(basename $(echo ${opt_md%%.option}))
	options="$options $opt"
    done
    echo $options
}
# get the default for the specified option
_rerunGetOptsDefault()
{
    local opt module command modulesdir opt_def
    modulesdir=$1 module=$2 command=$3 opt=$4
    opt_md=$modulesdir/$module/commands/$command/${opt##*-}.option
    awk -F= '/^DEFAULT/ {print $2}' $opt_md
}
# check if option takes an argument
_rerunHasOptsArgument()
{
    local opt module command modulesdir founddir
    modulesdir=$1 module=$2 command=$3 opt=$4
    opt_md=$modulesdir/$module/commands/$command/${opt##*-}.option
    opt_def=`awk -F= '/^ARGUMENTS/ {print $2}' $opt_md`
    [ "$opt_def" = "true" ] && return 0
    return 1
}



# program completion for the 'rerun' command.
_rerun() {
    [ -z "${RERUN_MODULES}" -o ! \( -d "${RERUN_MODULES}" \) ] && { 
		return 0 ; 
    }
    local cur prev context comp_line opts_module opts_command opts_module opts_args OPT 
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    context=()
    eval set $COMP_LINE
    shift; # shift once to drop the "rerun" from the argline

    #
    # Set up the context array...

	# Define regex pattern to parse command line input
	regex='([^:]+)([:]?[ ]?)([A-Za-z0-9_]*)([ ]*)(.*)'
	if [[ "$@" =~ $regex ]]
	then
		context[0]=${BASH_REMATCH[1]};    # module
		[ "${BASH_REMATCH[2]}" == ': ' ] && shift ;# eat the extra space char
		context[1]=${BASH_REMATCH[3]/ /}; # command
		# BASH_REMATCH[4] contains the whitespace between command and options
		capture[2]=${BASH_REMATCH[5]};    # options
	else
	    context[0]=${1/:/}                # module (minus colon)
	fi

    # Shift over to the command options
    shift;
  
    # 1. see if an existing module was specified. Set it, if so
    [ ${#context[@]} -gt 0 -a -n "${context[0]}" ] && {
		[ -n "${context[0]}" -a -d $RERUN_MODULES/${context[0]} ] && {	
	    	opts_module=${context[0]}	    
		}
    }
    # 2. see if an existing command was specified for a module. Set it, if so
    [ ${#context[@]} -gt 1 -a -n "$opts_module" ] && {
		_lexists ${context[1]} "$(_rerunListCommands ${RERUN_MODULES} ${opts_module})"  && {
	    	opts_command=${context[1]}
		}
    }
    # 3. see if command options are specified
    [ ${#context[@]} -eq 2 -a -n "$opts_command" ] && {
		opts_args=${context[2]}
    }    

    # List information pertaining to current context level. 
    # Context-level ordering goes from most qualified to least (command,module,empty)

    # Command context: List command-specific args 
    [ -n "$opts_command" -a -n "$opts_module" ] && {
        [ -f $RERUN_MODULES/$opts_module/commands/${opts_command}/default.sh ] && {
			local options=$(_rerunListOpts ${RERUN_MODULES} ${opts_module} ${opts_command})
            COMPREPLY=( $(compgen -W "$options" -P "-" -- ${cur}) )
            return 0
    	}
    }

    # Arg context: Process the command-specific arg(s)
    [ -n "$opts_args" ] && {
        [ -n "$opts_module" ] && {
            # check if current option takes an argument, and that prev matches -.*
            echo $prev | grep -q '^\-[^-].*' && $(_rerunHasOptsArgument ${RERUN_MODULES} ${opts_module} ${opts_command} ${prev}) && {
                local default
                default=$(_rerunGetOptsDefault ${RERUN_MODULES} ${opts_module} ${opts_command} ${prev})
                [ -n "$default" ] && {
                    COMPREPLY=( $(compgen -W "$default" -- ${cur}) )
                    return 0
                }  
                [ -z "$default" ] && {
                    echo $prev | egrep -q '^\-file.*|^\-out.*|^\-.*?file$|^\-xml.*' && {
                        # use filename completion in these cases
                	COMPREPLY=( $(compgen -o filenames -A file -- ${cur}) )
                    }
                    return 0
            	}
            } || {
        	# present the other options but filter out the previously used ones
            	usedargs=
	        for arg in ${comp_line##*--}
    	        do
        	    echo $arg | grep -q '\-[^-]*' && usedargs="$usedargs ${arg}"
            	done

                [ -n "$opts_module" ] && {
                    remaningargs=$(_lsubtract "$(_rerunListOpts ${RERUN_MODULES} ${opts_module} ${opts_command})" "$usedargs")
                    COMPREPLY=( $(compgen -W "$remaningargs" -- ${cur}) )
    	        }
            }
	}
	return 0
    }
    
    # Module context: list commands
    [ -n "$opts_module" -a -z "$opts_command" ] && {
		local commands=$(_rerunListCommands ${RERUN_MODULES} ${opts_module})
        COMPREPLY=( $(compgen -W "$commands" -- ${cur}) )
        return 0
    }
    
    # Empty context: list modules
    [ -z "$opts_module" ]  && {
		local modules=$(_listdirnames $RERUN_MODULES)
        COMPREPLY=( $(compgen -W "$modules" -S ':' -o nospace -- ${cur}) )
        return 0
    }    
}
# register the _rerun completion function
complete -F _rerun rerun
