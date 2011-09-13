# NAME

rerun - modular command runner

# SYNOPSYS

rerun [-M dir] [-m module [-c command]] [-- <command-options>]

# DESCRIPTION

Rerun is a simple module dispatching mechanism that looks up named
commands and executes them.

# OPTIONS

-h
: Print help and usage

-m *MODULE*
: Module name

-c *COMMAND*
: Command name

-M *DIRECTORY*
: Module library directory path

# MODULES

A rerun module assumes the following structure:

    <module>/
     |
     |- profile   (module metadata)
     |
     +-commands/
     |    |
     |    |- cmdA.sh (generic)
     |    `- cmdA-`uname -s`.sh (os-specific implementation)
     |
     +-lib/ (your own shell function definitions, etc)

The format of the metadata.sh uses key=value pairs to define standard
module metadata. For example, a module named `init`:

    module_name="init"
    module_description="Utility module containing various commands for managing services"
    module_commands="stop start"

# EXAMPLES

*Listing*

Without arguments (and a valid module lib) running `rerun` without arguments
will list existing modules:

    $ rerun
    Available modules:
    init

To list the commands available from the 'init' module add the '-m module' parameter

    $ rerun -m init
    Available init commands:
    start
    stop

*Executing*

To run the 'start' command, add the '-c command' parameter.

    rerun -m init -c start

If the 'init' module is stored in /var/rerun, then the command usage
would be:

    rerun -M /var/rerun -m init -c start


# ERROR CODE

0
: All commands executed successfully

1
: One or more commands failed

127
: Unknown error case

The rerun source code and all documentation may be downloaded from
<https://github.com/dtolabs/rerun/>.
