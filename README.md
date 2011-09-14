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

    <MODULE_DIR>
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
        └── options.sh (options parsing script)

The format metadata file format uses KEY=value pairs to define standard
attributes. For example, a module named `freddy` and can be named
and described as such in a file called `MODULE_DIR/etc/module`:

    NAME="freddy"
    DESCRIPTION="A dancer in a red beret and matching suspenders"

A command can also be named and described in a file called
`MODULE_DIR`/etc/commands/<command>/command`:

    NAME="study"
    DESCRIPTION="tell freddy to study"
    
Options can be additionally described in a file called
`MODULE_DIR/etc/commands/<command>/<option>.option`.
Here's one for an option named "subject":

    NAME=subject
    DESCRIPTION="the summer school subject"
    ARGUMENTS=true
    REQUIRED=true
    DEFAULT=math

Example directory structure:

    freddy
    ├── commands
    │   ├── dance.sh
    │   └── study.sh
    ├── etc
    │   ├── commands
    │   │   ├── dance
    │   │   │   ├── command
    │   │   │   ├── jumps.option
    │   │   │   └── options.sh
    │   │   └── study
    │   │       ├── command
    │   │       ├── options.sh
    │   │       └── subject.option
    │   └── module
    └── lib

# USING

## Listing

Without arguments, `rerun` will list existing modules:

    $ rerun
    [modules]
      freddy: "A dancer in a red beret and matching suspenders"

To list the commands available from the 'freddy' module add `-m module`:

    $ rerun -m freddy
    freddy:
    [commands]
     study: "tell freddy to study"
      [options]
       -subject <math>: "the summer school subject"
     dance: "tell freddy to dance"
      [options]
       -jumps <1>: "jump #num times"

### Bash completion

If you are a bash user be sure to source the `bash_completion.sh` file. 
It provides listing via the tab key.

Type `rerun` and then the tab key. The shell will generate
the "-m" and then a list of existing modules.

    $ rerun[TAB][TAB]

Will display:

    $ rerun -m stubbs

Typing the tab key again will show the commands inside the stubbs module:

    $ rerun -m stubbs -c add-[TAB]
    add-command  add-module   add-option     

After selecting a command, typing the tab key will show arguments.

    $ rerun -m stubbs -c add-command --[TAB]
    module name
    
## Executing

To run the 'study' command, add `-c command`:

    rerun -m freddy -c study
    
Tell freddy to study the subject, "biology":

    rerun -m freddy -c study -- -subject biology

If the 'freddy' module is stored in `/var/rerun`, then the command usage
would be:

    rerun -M /var/rerun -m freddy -c study

# ENVIRONMENT

RERUN_MODULES
: Path to directory containing rerun modules

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
