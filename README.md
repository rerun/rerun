# NAME

rerun - a simple command runner because it's easy to forget 
standard operating procedure.

# SYNOPSYS

	rerun [-h][-v][-V] [-M <dir>] [-L <dir>] [--checklog <file>] [module:[command [command_args]]]

# DESCRIPTION

Rerun is a lightweight tool building framework useful for those that 
implement management procedure with shell scripts. Rerun will help you
organize your implementation into well defined modular interfaces.
Collections of management modules can be archived and delivered as
a single executable to facilitate team hand offs.

Rerun provides two interfaces:

1. Listing: `rerun` lists modules and commands. Listing
information includes name, description and command line usage syntax.
2. Execution: Rerun provides option processing (possibly defaulting
unspecified arguments) and executes the specified module command.

For the module developer, rerun is a trivial framework following
simple conventions that easily fit in a shell context.
Rerun includes a module development tool called "stubbs" that
helps create and evolve rerun modules. Stubbs contains
commands to automate option processing code and metadata definition.

Internally, rerun implements a simple dispatching mechanism to look up named
commands and execute them. *Commands* are logically named and
have a corresponding script.

Commands reside in a module and can have named command line 
parameters called *options*. Each option is named and 
described and also be defined to have a default value 
or whether it is required input.

Rerun modules can optionally declare metadata describing name, description
and other aspects of each command. Rerun makes use of this metadata
to support a listing mode, a feature where modules and command usage
are summarized for end users.

See the [project wiki](https://github.com/dtolabs/rerun/wiki)
for additional documentation including:

* [Getting started](https://github.com/dtolabs/rerun/wiki)
* [Installation](https://github.com/dtolabs/rerun/wiki/Installation)
* [stubbs module tool](https://github.com/dtolabs/rerun/tree/master/modules/stubbs)
* [Why rerun?](https://github.com/dtolabs/rerun/wiki/Why-rerun%3F)

# OPTIONS

`-h`
: Print help and usage then exit.

`--checklog *LOG*`
: Compare the results of an execution to those of a previous command log and show the diff

`-M` *DIRECTORY*
: Module library directory path.

`-L` *DIRECTORY*
: Log directory path.

`-v` 
: Execute command in verbose mode. 

`-V` 
: Execute command and rerun in verbose mode. 


# USING

## Listing

Without arguments, `rerun` will list existing modules:

    $ rerun
    [modules]
      freddy: "A dancer in a red beret and matching suspenders"

To list the commands available from the 'freddy' module add `-m module`:

    $ rerun freddy
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

Options that declare a default value are shown
with a string between the "<>" characters.

For example, notice how "-jumps" option shows `<1>`.
The "1" is the default value assigned to the "jumps" option.

### Bash completion

If you are a bash shell user, be sure to source the `bash_completion.sh` file. 
It provides listing via the tab key.

Type `rerun` and then the tab key. The shell will generate
the `-m` option and then a list of existing modules.

    $ rerun[TAB][TAB]

Will display:

    $ rerun freddy

Typing the tab key again will show the commands inside the "freddy" module:

    $ rerun freddy: [TAB]
    dance  study     

In this case, two commands are found and listed.
After accepting a command, typing the tab key will show arguments.

    $ rerun freddy:study [TAB]
    subject

The "study" command accepts one option (subject).
    
## Executing

Commands are executed by supplying the module,
command and possibly options.

To run freddy module's "study" command, type:

    rerun freddy:study
    math

The string "math" is the printed result (and subject's default value).
    
Arguments to a called command are passed after
the module:command:
Tell freddy to study the subject, "biology":

    rerun freddy:study -subject biology
    studying (biology)

If the 'freddy' module is stored in `/var/rerun`, then the command usage
would be:

    rerun -M /var/rerun freddy:study
    studying (math)

### Bash self extracting archive executable

A set of modules and rerun itself can be archived into a self extracting
script. If the execute bit is set, just invoke the script directly:

    $ ./rerun.bin
    [modules]
    .
    .
    . listing output ommitted

If the execute bit is not set, run it via bash:

    $ bash rerun.bin <module>:<command> -your other options

Note, ".bin" is just a suffix naming convention for a bash self-extracing script.
The file can be named anything you wish.

### Checklog

Use the `--checklog <log>` option to compare execution output from a command log.
	
	$ ./rerun --checklog $RERUN_LOGS_/freddy-dance-2011-0921-140744.log freddy:dance -jumps 2
	jumps (2)
	[diff]
	2c2
	< jumps ()
	---
	> jumps (2)

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

* default.sh: Generic implementation.
* `uname -s`.sh: OS specific implementation
* options.sh: Script sourceable by default and OS specific scripts
  to parse options.

## Metadata

The metadata file format uses line separated KEY=value 
pairs to define module attributes. 

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

# ENVIRONMENT

`RERUN_MODULES`
: Path to directory containing rerun modules

`RERUN_LOGS`
: Path to directory where rerun will write log files

`RERUN_COLOR`
: Set 'true' if you want ANSI text effects. Makes
labels in text to print bold in the console.
Syntax errors will also print bold.

# LOGS

Rerun logs all command execution if the `-L <dir>` 
argument is set or the `RERUN_LOGS` environment variable is set.
Be sure to set `RERUN_LOGS` to a writable directory. 

*Log file names*

Each command execution is logged in a file named using the following pattern:

    $RERUN_LOGS/$MODULE-$COMMAND-YYYY-MMDD-HHMMSS.log

*Log file format*

Command logs use the following format.

	#
	# Rerun command execution log
	#
	RERUN="$RERUN"
	MODULE="$MODULE"
	COMMAND="$COMMAND"
	OPTIONS="$*"
	USER="$USER"
	DATE="$(date '+%Y-%m%d-%H%M%S')"
	__LOG_BELOW__

	
Any command output is stored below the line delimiter, `__LOG_BELOW__`.

# SEE ALSO

To create modules, see
[stubbs](https://github.com/dtolabs/rerun/tree/master/modules/stubbs).

# ERROR CODE

`0`
: All commands executed successfully

`1`
: One or more commands failed

`127`
: Unknown error case

# LICENSE

Copyright 2011 DTO Solutions

Licensed under the Apache License, Version 2.0 (the "License"); 
you may not use this file except in compliance with the License. 
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, 
software distributed under the License is distributed on an 
"AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, 
either express or implied. See the License for the specific 
language governing permissions and limitations under the License.

The rerun source code and all documentation may be downloaded from
<https://github.com/dtolabs/rerun/>.
