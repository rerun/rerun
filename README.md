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

## Layout

A rerun module assumes the following structure:

    <MODULE>
    ├── commands
    │   ├── cmdA (directory for cmdA files)
    │   │   ├── metadata (command metadata)
    │   │   ├── default.sh (generic script)
    │   │   ├── optX.option (declares metadata for "optX" option)
    │   │   └── options.sh (option parsing script)
    │   └── cmdB
    │       ├── Darwin.sh (OS specific script)
    │       ├── metadata
    │       ├── default.sh (generic script)
    │       ├── options.sh
    │       └── optY.option (declares metadata for "optY" option)
    ├── metadata (module metadata)
    └── lib

## Scripts

Rerun's internal dispatch logic follows the layout convention 
described above to find and execute scripts for each command.

Rerun expects a default implementation script for each command
but can also invoke an OS specific script, if present.

* default.sh: Generic implmentation.
* `uname -s`.sh: OS specific implementation
* options.sh: Script sourceable by default and OS specific scripts
  to parse options.

## Metadata

The metadata file format uses KEY=value pairs to define standard
attributes. 

* NAME: Declare name displayed to user.
* DESCRIPTION: Brief explanation of use.

For example, a module named `freddy` and can be named
and described as such in a file called `MODULE_DIR/metadata`:

    NAME="freddy"
    DESCRIPTION="A dancer in a red beret and matching suspenders"

Command metadata are described in a file called
`MODULE_DIR/commands/<command>/metadata`.
Here's one for the "study" command:

    NAME="study"
    DESCRIPTION="tell freddy to study"

Options can be
described in a file called `MODULE_DIR/commands/<command>/<option>.option`.
Beyond just NAME and DESCRIPTION, options can declare:

* ARGUMENTS: Does the option take an argument.
* REQUIRED: Is the option required.
* DEFAULT: Sensible value for an option default 

Here's `subject.option` describing an option named "subject":

    NAME=subject
    DESCRIPTION="the summer school subject"
    ARGUMENTS=true
    REQUIRED=true
    DEFAULT=math

Combining the examples above into the layout described earlier
the "freddy" module along with its commands "dance" and "study"
is illustrated here:

    freddy
    ├── commands
    │   ├── dance
    │   │   ├── metadata
    │   │   ├── default.sh
    │   │   ├── jumps.option
    │   │   └── options.sh
    │   └── study
    │       ├── metadata
    │       ├── default.sh
    │       ├── options.sh
    │       └── subject.option
    ├── metadata
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

The listing also includes option info including default
values if they were described with option metadata.

### Bash completion

If you are a bash shell user, be sure to source the `bash_completion.sh` file. 
It provides listing via the tab key.

Type `rerun` and then the tab key. The shell will generate
the `-m` option and then a list of existing modules.

    $ rerun[TAB][TAB]

Will display:

    $ rerun -m stubbs

Typing the tab key again will show the commands inside the "stubbs" module:

    $ rerun -m stubbs -c add-[TAB]
    add-command  add-module   add-option     

In this case, three commands are found and listed.
After accepting a command, typing the tab key will show arguments.

    $ rerun -m stubbs -c add-command --[TAB]
    module name

The "add-command" command accepts two options (module and name).
    
## Executing

Commands are executed by supplying the module,
command and possibly options.

To run freddy module's "study" command, type:

    rerun -m freddy -c study
    
Arguments to the called command are passed after
two dashes `--`. 
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
