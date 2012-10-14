#!/usr/bin/env bash
#
# NAME
#
#   docs
#
# DESCRIPTION
#
#   generate the docs
#
#/ usage: stubbs:docs --module|-m <>


# Parse the command options
[ -r $RERUN_MODULE_DIR/commands/docs/options.sh ] && {
  source $RERUN_MODULE_DIR/commands/docs/options.sh
}

# Source common function library
. $RERUN_MODULES/stubbs/lib/functions.sh || { echo >&2 "failed loading function library" ; exit 1 ; }

rerun_module_metadata() {
	local FIELD=$(echo $1|tr "[:lower:]" "[:upper:]")
	local metadata=$RERUN_MODULES/$2/metadata
	[ -f $metadata ] || return ; # skip weird file expansion
	awk -F= "/^$FIELD/ {print \$2}" $metadata
}

rerun_module_synopsys() {
	local module=$1
	local commands=( $(rerun_commands $RERUN_MODULES $module) )
	local list=$(printf "| %s " "${commands[@]}")
	echo "${module}: [${list:1}]"
}

rerun_command_metadata() {
	local FIELD=$(echo $1|tr "[:lower:]" "[:upper:]")
	local metadata=$RERUN_MODULES/$2/commands/${3}/metadata
	[ -f $metadata ] || return ; # skip weird file expansion
	awk -F= "/^$FIELD/ {print \$2}" $metadata
}

rerun_option_metadata() {
	local FIELD=$(echo $1|tr "[:lower:]" "[:upper:]")
	local metadata=$RERUN_MODULES/$2/commands/${3}/$4.option
	[ -f $metadata ] || return ; # skip weird file expansion	
	awk -F= "/^$FIELD/ {print \$2}" $metadata
}

rerun_command_usage() {
	for opt_metadata in $RERUN_MODULES/$1/commands/${2}/*.option; do
		[ -f $opt_metadata ] || continue ; # skip weird file expansion
		option=$(basename $opt_metadata)
		printf "%s %s\n" "$PAD" "$(rerun_option_summary $1 $2 ${option%*.option} )"
	done
}
rerun_command_summary() {
	declare -a summary=()
	for opt_metadata in $RERUN_MODULES/$1/commands/${2}/*.option; do
		[ -f $opt_metadata ] || continue ; # skip weird file expansion
		option=$(basename $opt_metadata)
		typeset -a arr=( "$(rerun_option_summary $1 $2 ${option%*.option} )" )
		param="${arr[@]:0:1}"
		summary=( ${summary[@]} ${param%:*} )
	done
	echo ${summary[*]}
}

rerun_option_summary() {
	opt_name=$3
	opt_desc=$(rerun_option_metadata "description" $1 $2 $opt_name)
	opt_arg=$(rerun_option_metadata "arguments" $1 $2 $opt_name)
	opt_req=$(rerun_option_metadata "required" $1 $2 $opt_name)
	opt_def=$(rerun_option_metadata "default" $1 $2 $opt_name)
	# option usage summary
	opt_usage=$(printf " --%s <%s>: %s" "${opt_name}" "${opt_def}" "${opt_desc}")
	[ "true" != "${opt_req}" ] && {
		opt_usage=$(printf "[--%s <%s>]: %s" "${opt_name}" "${opt_def}" "${opt_desc}") 
	}
	printf "%s %s\n" "$PAD" "$opt_usage"
}

[ -f "$RERUN_MODULES/$MODULE/metadata" ] || rerun_die "module not found: $MODULE"


#
# Document head
(
cat <<EOF
.TH $MODULE 1 "$(date)" "Version 1" "Rerun User Manual" 
.SH NAME
$MODULE \- $(rerun_module_metadata "description" $MODULE)
.PP
.SH SYNOPSIS
.PP
\f[CR] 
$(basename ${RERUN}) [ARGS] $(rerun_module_synopsys $MODULE) [OPTIONS]
\f[]
EOF
) > $FILE || rerun_die
#
# COMMANDS section
#
echo ".SH COMMANDS" >> $FILE
for command in $(rerun_commands $RERUN_MODULES $MODULE)
do
(
cat <<EOF
.SH $MODULE:$command \f[]$(rerun_command_summary $MODULE $command)
$(rerun_command_metadata description $MODULE $command)
.PP
\f[I]OPTIONS\f[]
$(for option in $(rerun_options $RERUN_MODULES $MODULE $command)
do
description=$(rerun_option_metadata "description" $MODULE $command $option)
arguments=$(rerun_option_metadata "arguments" $MODULE $command $option)
default=$(rerun_option_metadata "default" $MODULE $command $option)
required=$(rerun_option_metadata "required" $MODULE $command $option)
echo .TP
echo .B \\--$option \\f[]$description\\f[]
echo "required: \\f[I]${required}\\f[] ,"
echo "arguments: \\f[I]${arguments}\\f[]"
[ -n "$default" ] && echo ", default: \\f[I]$default\\f[]"
echo .RS
echo .RE
done)
EOF
) >> $FILE || rerun_die
done || rerun_die
#
# AUTHORS section
(
cat <<EOF
.SH RETURN VALUES
.PP
Successful completion: 0
.SH AUTHORS
$USER
EOF
) >> $FILE || rerun_die
#
# SEE ALSO section
(
cat <<EOF
.SH "SEE ALSO"
rerun
.SH KEYWORDS
$MODULE
EOF
) >> $FILE || rerun_die

echo "Generated unix manual: $FILE"
exit $?

# Done
