#
# common shell functions for @MODULE@ commands
#

#
# colorizing functions -
#

# bold - bold the given text
bold() { echo -e "\033[1m$*\033[0m" ; reset ; }
# reset the terminal
reset () { tput sgr0 ; }

#
# error handling functions -
#

# print error message and exit
rerun_die() {
    [[ "$RERUN_COLOR" == "true" ]] && bold "$*" >&2 || echo "$*" >&2
    exit 1
}


PAD="  "

# print usage for a single option
rerun_option_usage() {
    module=${1%:*} command=${1#*:} option=$2
    opt_metadata=$RERUN_MODULES/$module/commands/$command/$option.option
    [ ! -f $opt_metadata ] && return
    opt_name=`awk -F= '/^NAME/ {print $2}' $opt_metadata`
    opt_desc=`awk -F= '/^DESCRIPTION/ {print $2}' $opt_metadata`
    opt_arg=`awk -F= '/^ARGUMENTS/ {print $2}' $opt_metadata`
    opt_req=`awk -F= '/^REQUIRED/ {print $2}' $opt_metadata`
    opt_def=`awk -F= '/^DEFAULT/ {print $2}' $opt_metadata`
    opt_short=`awk -F= '/^SHORT/ {print $2}' $opt_metadata`
    argstring=
    [ -n "${opt_short}" ] && {
	argstring=$(printf ' -%s|--%s' "${opt_short}" "${opt_name}")
    } || {
	argstring=$(printf " --%s" "${opt_name}" )
    }
    [ "true" == "${opt_arg}" ] && {
	argstring=$(printf "%s <%s>" $argstring ${opt_def})
    }
    [ "true" != "${opt_req}" ] && {
	opt_usage=$(printf "[%s: %s]" "${argstring}" "${opt_desc}") 
    } || {
	opt_usage=$(printf "%s: %s" "${argstring}" "${opt_desc}")
    }
    printf "%s %s\n" "$PAD" "$opt_usage"
}

# print usage for all options in the command
rerun_command_usage() {
    module=${1%:*} command=${1#*:}
    metadata=$RERUN_MODULES/$module/commands/${command}/metadata
    [ -f $metadata ] && desc=`awk -F= '/^DESCRIPTION/ {print $2}' $metadata`
    echo "Usage: "
    echo " ${command}: ${desc}"
    printf "%s%s\n" "$PAD" "[options]"
    shopt -s nullglob # enable
    for opt_metadata in $RERUN_MODULES/$module/commands/${command}/*.option; do
	option=$(basename $(echo ${opt_metadata%%.option}))
	rerun_option_usage ${module}:${command} $option
    done
}


# print command usage and return
rerun_option_error() {
    module=${1%:*} command=${1#*:}
    rerun_command_usage $module $command >&2
    return 2
}

# check option has its argument
rerun_option_check() {
    [ "$1" -lt 2 ] && return 2
}

# initialize the module. This is just a hook. 
rerun_command_initialize() {
    : ; # do nothing
}

rerun_command_initialize