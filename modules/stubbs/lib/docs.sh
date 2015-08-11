
docs_module_synopsis() {
	local -r module=$1
	local commands=( $(rerun_commands $RERUN_MODULES $module) )
	local list=$(printf "| %s " "${commands[@]}")
	echo "${module}: [${list:1}]"
}

docs_option_summary() {
    local -r opt_dir=$1
	local opt_name=$(rerun_property_get $opt_dir NAME)
	local opt_desc=$(rerun_property_get $opt_dir DESCRIPTION)
	local opt_arg=$(rerun_property_get $opt_dir ARGUMENTS)
	local opt_req=$(rerun_property_get $opt_dir REQUIRED)
	local opt_def=$(rerun_property_get $opt_dir DEFAULT false)
	# option usage summary
	local opt_usage=$(printf " --%s <%s>: %s" "${opt_name}" "${opt_def}" "${opt_desc}")
	[ "true" != "${opt_req}" ] && {
		opt_usage=$(printf "[--%s <%s>]: %s" "${opt_name}" "${opt_def}" "${opt_desc}") 
	}
	printf "%s %s\n" "$PAD" "$opt_usage"
}

docs_command_summary() {
	local -a summary=()
    local rerun_module_home_dir=$(rerun_module_exists $1)
    options=( $(. $rerun_module_home_dir/commands/$2/metadata; echo $OPTIONS) )
	for option in ${options[*]:-}; do
        optdir=$rerun_module_home_dir/options/$option
		local -a arr=( "$(docs_option_summary $optdir)" )
		param="${arr[@]:0:1}"
		summary=( ${summary[@]:-} ${param%:*} )
	done
	echo ${summary[*]:-}
}

#
# - - -
#

# _docs_html_layout_ - Create a function for apply the standard HTML layout.
#
#     docs_html_layout title < stdin
#
# Arguments:
#
# * title:     Page title
# * css:       Path to the css file

# Notes: 
#
# * Page body content piped to stdin.
# * Credit: rtomayko and shocco.
# 
docs_html_layout() {
    [[ ! $# -eq 2 ]] && { 
	    rerun_die 'usage: ${FUNCNAME} title css'
    }
    local -r title=$1 css=$2
    cat <<HTML
<!DOCTYPE html>
<html>
<head>
    <meta http-eqiv='content-type' content='text/html;charset=utf-8'>
    <title>${title:-}</title>
    <link rel=stylesheet type="text/css" 
          href="$css">
</head>
<body>
 <div id=container>
   $(cat)
 </div>
</body>
</html>
HTML
}

#
# - - -
#

# _docs_metadata_to_md_ - Generate markdown from metadata
#
#     docs_metadata_to_md file
#
# Arguments:
#
# * file:     Metadata file
#
# Notes: 
#
# * Formatted as unordered list.
#
docs_metadata_to_md() {
    [[ ! $# -eq 1 ]] && { 
	    rerun_die 'usage: ${FUNCNAME} file'
    }
    local -r metadata=$1
    regex="(^[[:alnum:]]+)=(.*)"
    while read line
    do
        [[ $line =~ $regex ]] || continue
        echo "* \`${BASH_REMATCH[1]}\` = ${BASH_REMATCH[2]}"
    done < $metadata
    return $?

}

#
# - - -
#

# _docs_option_to_md_ - Generate a mardkown page for an option.
#
#     docs_option_to_md metadata module
#
# Arguments:
#
# * metadata:     option metadata
# * module:       module name
#
# Notes: 
#
# * Formatted as unordered list.
# * Written to stdout
#
docs_option_to_md() {
    [[ ! $# -eq 2 ]] && { 
	    rerun_die 'usage: ${FUNCNAME} metadata module'
    }
    local -r metadata=$1 module=$2
    local -r opt_dir=$(dirname $metadata)
    local -r opt_name=$(basename $opt_dir)
    local -r opt_summary=$(docs_option_summary $opt_dir)
    local -r rerun_module_home_dir=$(rerun_module_exists $module)
    
    cat <<MARKDOWN
[$module](../../index.html)

# $opt_name

$(rerun_property_get $opt_dir DESCRIPTION)

## SYNOPSIS

    ${opt_summary%:*}

## README

$(test -f $opt_dir/README.md && cat $opt_dir/README.md)

## COMMANDS

The following commands use this option.

$(for command in $(stubbs_option_commands $rerun_module_home_dir $opt_name)
do
printf '* [%s](../../commands/%s/index.html)\n' $command $command
done)

## METADATA

$(docs_metadata_to_md $metadata)

----

*Generated by stubbs:docs $(date)*

MARKDOWN

}

#
# - - -
#

# _docs_testplan_to_md_ - Generate a mardkown list of test functions
#
#     docs_testplan_to_md file
#
# Arguments:
#
# * file:     testplan file
#
# Notes: 
#
# * Formatted as unordered list.
#
docs_testplan_to_md() {
    [[ ! $# -eq 1 ]] && { 
	    rerun_die 'usage: ${FUNCNAME} file'
    }
    local -r testfile=$1
    local -r regex="^(it_[^\(]+).*"
    while read line
    do
        [[ $line =~ $regex ]] || continue
        funcname=${BASH_REMATCH[1]}        
        echo "  * $(echo $funcname | tr '_' ' ')"
    done < $testfile
    return $?        
}

#
# - - -
#

# _docs_test_to_md_ - Generate markdown for a test.
#
#     docs_test_to_md file
#
# Arguments:
#
# * file:     the test file.
# * module:   the module name.
#
# Notes: 
#
# * Written to stdout
#
docs_test_to_md() {
    [[ ! $# -eq 2 ]] && { 
	    rerun_die 'usage: docs_test_to_md file module'
    }    
    local -r file=$1 module=$2
    local -r test_file=$(basename $file)
    local -r test_name=${test_file%*-test.sh}
    cat <<MARKDOWN

Use the \`stubbs:test\` command to to run test plans.

    rerun stubbs:test -m $module -p $test_name

*Test plan sources*

* [$test_name](tests/$test_name.html)
$(docs_testplan_to_md $file)

MARKDOWN
}


#
# - - -
#

# _docs_command_to_md_ - Generate a mardkown page for a command.
#
#     docs_command_to_md metadata module
#
# Arguments:
#
# * metadata:     command metadata
# * module:       module name
#
# Notes: 
#
# * Written to stdout
#
docs_command_to_md() {
    [[ ! $# -eq 2 ]] && { 
	    rerun_die 'usage: docs_command_to_md metadata module'
    }
    local -r metadata=$1 module=$2 
    local -r com_dir=$(dirname $metadata)
    local -r com_name=$(basename $com_dir)
    local -r com_summary=$(docs_option_summary $com_dir)
    local -r rerun_module_home_dir=$(rerun_module_exists $module)

    cat <<MARKDOWN
[$module](../../index.html)
# $com_name 

$(rerun_property_get $com_dir DESCRIPTION)

## SYNOPSIS

    rerun $module:$com_name $(docs_command_summary $module $com_name)

### OPTIONS

$(for option in $(rerun_options $RERUN_MODULES $module $com_name)
do
echo "* [$(docs_option_summary $rerun_module_home_dir/options/$option)](../../options/$option/index.html)"
done)

## README

$(test -f $com_dir/README.md && cat $com_dir/README.md)

## TESTS

Use the \`stubbs:test\` command to to run test plans.

    rerun stubbs:test -m $module -p $com_name

*Test plan sources*

$(for test in $(find $rerun_module_home_dir/tests -name $com_name\*-test.sh)
do
   test_file=$(basename $test)
   test_name=${test_file%*-test.sh}

   echo "* [$test_name](../../tests/$test_name.html)"
   docs_testplan_to_md $test
done)

## SCRIPT

To edit the command script for the $module:$com_name command, 
use the \`stubbs:edit\`
command. It will open the command script in your shell EDITOR.

    rerun stubbs:edit -m $module -c $com_name

*Script source*

* [script](script.html): \`RERUN_MODULE_DIR/commands/$com_name/script\`

## METADATA

$(docs_metadata_to_md $metadata)

----

*Generated by stubbs:docs $(date)*

MARKDOWN
}

#
# - - -
#

docs_man_page() {
    [[ ! $# -eq 2 ]] && { 
	    rerun_die "usage: docs_man_page version module: $@"
    }    
    local -r version=$1 module=$2
    local -r rerun_module_home_dir=$(rerun_module_exists $module)
(
cat <<ROFF
.TH $module 1 "$(date)" "Version ${version}" "RERUN User Manual" 
.SH NAME
$module \- $(rerun_property_get $rerun_module_home_dir DESCRIPTION)
.PP
.SH SYNOPSIS
.PP
\f[CR] 
$(basename ${RERUN}) [ARGS] $(docs_module_synopsis $module) [OPTIONS]
\f[]

.SH COMMANDS
$(for command in $(rerun_commands $RERUN_MODULES $module)
do
cat <<EOF
.SH $module:$command \f[]$(docs_command_summary $module $command)

$(rerun_property_get $rerun_module_home_dir/commands/$command DESCRIPTION)
.PP
\f[I]OPTIONS\f[]
$(for option in $(rerun_options $RERUN_MODULES $module $command)
do
optdir=$rerun_module_home_dir/options/$option
description=$(rerun_property_get $optdir DESCRIPTION)
arguments=$(rerun_property_get $optdir ARGUMENTS)
default=$(rerun_property_get $optdir DEFAULT)
required=$(rerun_property_get $optdir REQUIRED)
echo .TP
echo .B \\--$option \\f[]$description\\f[]
echo "required: \\f[I]${required}\\f[] ,"
echo "arguments: \\f[I]${arguments}\\f[]"
[ -n "$default" ] && echo ", default: \\f[I]$default\\f[]"
echo .RS
echo .RE
done)
EOF
done) ; # command section done.

.SH RETURN VALUES
.PP
Successful completion: 0
.SH AUTHORS
$USER
.SH "SEE ALSO"
rerun
.SH KEYWORDS
$module
ROFF
)
}
