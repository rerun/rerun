Use *stubbs:edit* to edit a command script.

Basic usage
-----------

After creating a command with [stubbs:add-command](../add-command/index.html),
edit its script to give it the desired implementation.
Using `stubbs:edit`, supplying the module and command name,
the command will lookup the file path to the command script 
and open it to a text editor.
Below, the script for the waitfor:ping command is opened
for edit.

    rerun stubbs:edit --module waitfor --command ping

The `edit` command will open the command script file:
`$RERUN_MODULES/waitfor/commands/ping/script`.

The stubbs:edit command defaults to `vi` if 
the "EDITOR" environment variable is not defined.
Echo the `$EDITOR` environment variable to see the current text
editor defined for your shell.

Internal details
----------------

Opening the generated script file will show something similar
to the content below (some of the comment lines have been left out).

    #!/usr/bin/env bash
     
    #/ command: waitfor:ping: "wait for ping response from host"
    #/ usage: rerun waitfor:ping [options]
     
    . $RERUN_MODULE_DIR/lib/functions.sh ping || { 
      echo >&2 "Failed loading function library." ; exit 1 ; 
    }
     
    trap 'rerun_die $? "*** command failed: waitfor:ping. ***"' ERR
    set -o nounset -o pipefail
     
    #/ rerun-variables: RERUN, RERUN_VERSION, RERUN_MODULES, RERUN_MODULE_DIR
    #/ option-variables: HOST INTERVAL
     
    rerun_options_parse "$@"
     
    # Command implementation
    # ----------------------
     
    # - - -
    # Put the command implementation here.
    # - - -
     
    # Done. Exit with last command exit status.
     
    exit $?

For the most part, you should just be concerned with
filling out the "Command implementation" part of the
file. 

The name and description supplied via add-command options 
are inserted as special comments at the top. Comments
that begin with `#/` are managed by stubbs commands
and their content is changed to reflect a module's 
current definition.

The `rerun_die` function is applied to the `trap` command
in case things go awry and to fail fast in case of errors.

The [stubbs:add-option](../add-option/index.html)
command generates a function called `rerun_options_parse`. When your 
command is run, all options and their arguments are parsed 
by the function and returned as shell variables 
to your command script.

Naturally, your implementation code goes between the rows 
of dashes. For this example, insert a trivial implementation
that references the already defined "--host <>" and "--interval <>"
options:

    # - - -
    until ( ping -c 1 $HOST | grep -iq ^64 )
    do
       sleep $INTERVAL
       echo Pinging $HOST...
    done

    echo "OK: $HOST is pingable."
    # - - -

    exit $?

The last line is not the least important. 
Always faithfully check and return useful exit codes!
This makes commands predicibale and safer to use
and keeps with the "fail fast" philosophy.

_Verbosity?_

What happens when your command script fails and all you 
see is one line of cryptic error text? Shed more light 
by enabling verbose output using rerun's `-v` flag.

Adding '-v' effectively has `rerun` call the command script 
using bash's "-vx" flags.

Here's a snippet of the waitfor:ping command with 
verbose output:

    rerun -v waitfor:ping --host localhost
    .
    . <snipping out most of the verbose output ... >
    .
    # - - -
    until ( ping -c 1 $HOST | grep -iq ^64 )
    do
        sleep $INTERVAL
        echo Pinging $HOST...
    done
    + ping -c 1 localhost
    + grep -iq '^64'
     
    echo "OK: $HOST is pingable."
    + echo 'OK: localhost is pingable.'
    OK: localhost is pingable.
     
    # - - -
    exit $?
    + exit 0
