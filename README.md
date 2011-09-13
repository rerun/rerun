# NAME

rerun - a simple command runner because it's easy to forget normal procedure.

# SYNOPSYS

rerun [-M modules_dir] [-m module [-c command]] [-- command_options]

# DESCRIPTION

Rerun implements a simple dispatching mechanism that looks up named
commands and executes them. *Commands* are logically named and
have a corresponding script, `rerun` executes.

Commands reside in a module and can have named paramaters called *options*.

Rerun modules can optionally declare metadata describing name, description
and other aspects of each command. Rerun makes use of this metadata
to support a listing mode, a feature where modules and command usage
are summarized for end users.

# OPTIONS

-h
: Print help and usage.

-m *MODULE*
: Module name.

-c *COMMAND*
: Command name.

-M *DIRECTORY*
: Module library directory path.

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
module metadata. For example, a module named `freddy`:

    NAME="freddy"
    DESCRIPTION="A dancer in a red beret and matching suspenders"

The format for command data.

    NAME="study"
    DESCRIPTION="tell freddy to study"
    
The format for option data.

    NAME=subject
    DESCRIPTION="the summer school subject"
    ARGUMENTS=true
    REQUIRED=true
    DEFAULT=math

Example directory structure:

    freddy
    ├── README.md
    ├── commands
    ├── |-- dance.sh
    │   └── study.sh
    ├── etc
    │   ├── commands
    │   │   └── dance
    │   │       └── jumps.option    
    │   │   └── study
    │   │       └── subject.option
    │   └── module 
    └── lib

# USING

## Listing

Without arguments, `rerun` will list existing modules:

    $ rerun
    [modules]
      freddy: "A dancer in a red beret and matching suspenders"

To list the commands available from the 'freddy' module add the '-m module' parameter

    $ rerun -m freddy
    freddy:
    [commands]
     study: "tell freddy to study"
      [options]
       -subject <math>: "the summer school subject"
     dance: "tell freddy to dance"
      [options]
       -jumps <1>: "jump #num times"

## Executing

To run the 'study' command, add the '-c command' parameter.

    rerun -m freddy -c study
    
Tell freddy to study to the house

    rerun -m freddy -c study -- -place outside    

If the 'freddy' module is stored in /var/rerun, then the command usage
would be:

    rerun -M /var/rerun -m freddy -c study

# SEE ALSO

To create modules, see the `stubbs` command set.

# ERROR CODE

0
: All commands executed successfully

1
: One or more commands failed

127
: Unknown error case

The rerun source code and all documentation may be downloaded from
<https://github.com/dtolabs/rerun/>.
