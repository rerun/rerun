#
# common shell functions for @MODULE@ commands
#


# __Colorizing functions__


# Unset `RERUN_COLOR` to disable.
txtrst () { tput sgr0 ; }
bold() { echo -e "\033[1m$*\033[0m" ; txtrst ; }
dim() { tput dim ; echo " $*" ; txtrst ; }
[ -n "$RERUN_COLOR" ] && {
    ul="\033[4m" ; _ul="\033[0m" ; # underline
    gray="\033[38;5;238m" ; _gray="\033[0m" ; # gray
    red="\033[31m" ; _red="\033[0m" ; # red
    bold="\033[1m$*\033[0m" ; _bold="\033[0m" ; # bold
}

#
# error handling functions -
#

# Print the message and exit.
# Use text effects if `RERUN_COLOR` environment variable set.
rerun_die() {
    if [[ "$RERUN_COLOR" == "true" ]]
    then echo -e ${red}"ERROR: $*"${_red} >&2 
    else echo "ERROR: $*" >&2
    fi
    exit 1
}

