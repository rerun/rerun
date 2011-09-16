# stubbs: A module and command set to create rerun modules

Use `stubbs` to define new *rerun* modules and commands.

Stubbs provides a small set of commands that 
help you define and organize modules according to
rerun layout conventions and metadata format. 

It won't write your implementations for you but
helps you stay in between the guard rails!

## Commands

### add-module

Create a new rerun module.

*Usage*

    rerun -m stubbs -c add-module -- [-name <>] [-description <>]
    
*Example*

Make a new module named "freddy":

    rerun -m stubbs -c add-module  -- -name freddy -description "A dancer in a red beret and matching suspenders"

The `add-module` command will print:

    Created module structure: /Users/alexh/.rerun/modules/freddy

### add-command

Create a command in the specified module and generate a default implementation.

*Usage*

    rerun -m stubbs -c add-command -- -name <> -description <> -module <> [-ovewrite <false>]

*Example*

Add a command named "dance" to the freddy module:

    rerun -m stubbs -c add-command -- -name dance -description "tell freddy to dance" -module freddy

The `add-command `module will generate a boilerplate script you can edit.

    Wrote command handler: /Users/alexh/.rerun/modules/freddy/commands/dance/default.sh

### add-option

Define a command option for the specified module and generate options parser script.

*Usage*

    rerun -m stubbs -c add-option  -- [-arg <true>] -name <> -description <> -module <> -command <> [-required <false>]

*Example*

Define an option named "jumps":

    rerun -m stubbs -c add-option  -- -name jumps -description "jump #num times" -module freddy -command dance

You will see output similar to:

    Created option: /Users/alexh/.rerun/modules/freddy/commands/dance/jumps.option

Besides the `jumps.option` file, `add-option` also generates an
option parsing script: `$RERUN_MODULES/$MODULE/commands/$COMMAND/options.sh`.

The `default.sh` script sources the `options.sh` script to take care of
command line option parsing.

Users will now be able to specify a "-jumps" argument to freddy's "dance" command:

    $ rerun -m freddy
    freddy:
    [commands]
     dance: tell freddy to dance
      [options]
        -jumps <>: "jump #num times"

It would be invoked like so:

    rerun -m freddy -c dance -- -jumps 3

### archive

Create a self extracting archive script 
useful for launching a rerun environment.

`archive` generates a script that takes the same argument
list as `rerun`. It basically is a wrapper around launching
`rerun` from the context of an extracted archive.

*Usage*

    rerun -m stubbs -c archive -- [-file <rerun.bsx>] [-modules<*>]

*Example*

Create an archive containing the "freddy" module:

    rerun -m stubbs -c archive -- -modules "freddy"

The `archive` command generates a rerun.bsx script 
in the current directory.

Run the self extracting archive script without options and you
will see freddy's command listed:

    $ bash rerun.bsx
    freddy:
    [commands]
     dance: tell freddy to dance
      [options]
        -jumps <>: "jump #num times"

Now run freddy's "dance" command.

    $ bash rerun.bsx -m freddy -c dance -- -jumps 10
    jumps (10)

It works like a normal `rerun` command. Amazing !

## Command implementation

Running `add-command` as shown above will generate a stub default implementation
for the new command: `$RERUN_MODULES/$MODULE/commands/$COMMAND/default.sh`:

The dance command's `default.sh` stub is shown below:

    #!/bin/bash
    #
    # NAME
    #
    #   dance 
    #
    # DESCRIPTION
    #
    #   tell freddy to dance
     
    # Function to print error message and exit
    die() {
        echo "ERROR: $* " ; exit 1;
    }
     
    # Parse the command options     
    [ -r $RERUN_MODULES/freddy/commands/dance/options.sh ] && {
       . $RERUN_MODULES/freddy/commands/dance/options.sh
    } 
     
    # ------------------------------
    # Your implementation goes here.
    # ------------------------------
     
    exit $?

The name and description supplied via `add-command` options
are inserted as comments at the top.

A `die` function is provided for convenience in case things go awry.

Rather than implement a specialized option parser logic inside
each command implementation, `add-option` generates a reusable
script sourced by the command implementation script.
When your command is run all arguments passed after the "--"
are parsed by the options.sh script.

Naturally, your implementation code goes between the rows
of dashes. 
For this example, insert `echo "jumps ($JUMPS)` as a trivial
implementation:

    # ------------------------------
    echo "jumps ($JUMPS)"
    # ------------------------------
    
    exit $?

Always faithfully check and return useful exit codes!

Try running the command:

    $ rerun -m freddy -c dance -- -jumps 3
    jumps (3)

The "jumps (3)" is written to the console stdout.

Run "dance" again but this time without options.

    $ rerun -m freddy -c dance
    jumps ()

This time an empty pair of parenthesis are printed.
The problem here is the `$JUMPS` variable was not set
so an empty string is printed instead.
    
### Option defaults

If a command option is not supplied by the user, the
`option.sh` script (created by `add-option`) 
can set a default value.

Call the `add-option` command again but this
time use its `-default <>` parameter to set the default value. 

Here the "jumps" option is set to a default value, "1":

    rerun -m stubbs -c add-option  -- \
      -name jumps -description "jump #num times" -module freddy -command dance \
      -default 1

The `add-option` will update the `jumps.option` metadata file with the
new default value and extend the `options.sh` script.

Run the "dance" command again but this time without the "jumps" option:

    $ rerun -m freddy -c dance
    jumps (1)

We see the default value "1" printed.
    
You might be interested in the `options.sh` script
that's created behind the scenes.
Below, the "dance" command's `options.sh` script is shown.
It defines a while loop 
and supporting shell functions to process command line input.

The meat of the script is the while loop and case statement.
In the body of the case statement, you can see a case for
the "-jumps" option and the `JUMPS` variable that will be set
to the value of the "-jumps" argument.

    # generated by add-option
    # Tue Sep 13 20:11:52 PDT 2011
     
    # print error message and exit non-zero
    rerun_syntax_error() {
        echo "SYNTAX ERROR" >&2 ; exit 2;
    }
    # check option has its argument
    rerun_syntax_check() {
        [ "$1" -lt 2 ] && syntax_error
    }
     
    # options: [jumps]
    while [ "$#" -gt 0 ]; do
        OPT="$1"
        case "$OPT" in
            -jumps) rerun_syntax_check $# ; JUMPS=$2 ; shift ;;
            # unknown option
            -?)
                rerun_syntax_error
                ;;
            # end of options, just arguments left
            *)
              break
        esac
        shift
    done
          
    # If defaultable options variables are unset, set them to their DEFAULT
    [ -z "$JUMPS" ] && { JUMPS=1 ; }
     
Below the `while` loop, you can see a test for the
JUMPS variable (check for a non empty string).
A statement like this is added for options that declare 
`DEFAULT` metadata.

Separating options processing into the `options.sh` script,
away from the command implementation logic in `default.sh`, facilates
additonal options being created. It also helps "stubbs"
preserve changes you make to `default.sh`.

### OS specific command implementations

Your command's `default.sh` implementation may not work in all operating
system environments due to command and/or syntax differences.

Rerun will look for an operating system specific 
command implementation and run it instead, if it exists.

Effectively, rerun checks for a file named: 
`$MODULE/commands/$COMMAND/$(uname -s).sh`

For example, run `uname -s` on a centos host. It returns "Linux".

    $ uname -s
    Linux

So, to create a Linux OS specific implmentation,
create a script called `Linux.sh`. Copy default.sh
as a starting point:

    cp freddy/commands/dance/default.sh freddy/commands/dance/Linux.sh

Running the `tree` command shows the directory structure.

    freddy
    └── commands
        └── dance
            ├── Linux.sh (os-specific implementation)
            └── default.sh (generic one)
	    
Inside the Linux.sh script, replace the implementation with:

     "echo I'm a locker"
     
Run freddy's "dance" command:

    $ rerun -m freddy -c dance
    I'm a locker

The result comes from the execution of the new Linux.sh script.
