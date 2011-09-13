# NAME

rerun - modular command runner

# SYNOPSYS

rerun [-M dir] [-m module [-c command]] [-- command_options]

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

    <module>
    ├── README.md
    ├── commands
    │   ├── cmdA.sh (generic)
    │   └── cmdA-`uname -s`.sh (os-specific)
    ├── etc
    │   ├── commands
    │   │   └── cmdA
    │   │       ├── arg1.option (option metadata)
    │   │       └── arg2.option
    │   └── module (module metadata)
    └── lib
        └── command.sh (optional shell functions)

The format of the metadata.sh uses key=value pairs to define standard
module metadata. For example, a module named `fitz`:

    NAME="fitz"
    DESCRIPTION="A yellow dog that barks and walks"

# EXAMPLES

*Listing*

Without arguments, running `rerun` without arguments
will list existing modules:

    $ rerun
    [modules]
      fitz: "A yellow dog that barks and walks"

To list the commands available from the 'fitz' module add the '-m module' parameter

    $ rerun -m fitz
    fitz:
    [commands]
     walk: "go some where"
      [options]
       -place <doghouse>: "the destination"
     bark: "say something"
      [options]
       -message <woof>: "vocalize what"

*Executing*

To run the 'walk' command, add the '-c command' parameter.

    rerun -m fitz -c walk

If the 'fitz' module is stored in /var/rerun, then the command usage
would be:

    rerun -M /var/rerun -m fitz -c walk


# ERROR CODE

0
: All commands executed successfully

1
: One or more commands failed

127
: Unknown error case

The rerun source code and all documentation may be downloaded from
<https://github.com/dtolabs/rerun/>.
