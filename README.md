# NAME

rerun - a simple command runner because it's easy to forget 
standard operating procedure.

# SYNOPSYS

	rerun [-h][-v][-V] [-M <dir>] [-L <dir>] [module:[command [options]]]

# DESCRIPTION

Rerun is a simple command runner that turns loose shell scripts
into modular automation. Rerun will help you
organize your implementation into well defined command interfaces.
Collections of management modules can be archived and delivered as
a single executable to facilitate team hand offs.
Using the "stubbs" module, rerun will even facilitate unit tests.
When users execute rerun module commands, rerun can record 
execution data into log files.

Rerun provides two modes of operation:

1. *Listing*: Rerun lists modules and commands. Listing
information includes name, description and command line usage syntax.
2. *Execution*: Rerun provides option processing (possibly defaulting
unspecified arguments) and executes a script for the specified module command.

For the module developer, rerun is a trivial framework following
simple conventions that easily fit in a shell environment.
Rerun includes a module development tool called "stubbs" that
helps create and evolve rerun modules. Stubbs contains
commands to automate option processing code, metadata definition
and unit testing.

Internally, `rerun` implements a simple dispatching mechanism to look up named
commands and execute them. *Commands* are logically named and
have a corresponding script.

Commands reside in a module and can have named 
parameters called *options*. Each option is named,
described and can also be defined to use a default value 
or say whether it is required or not.

Rerun modules can also declare metadata describing name, description
and other aspects of each command. Rerun makes use of this metadata
to support a listing mode, a feature where modules and command usage
are summarized for end users.

See the [project wiki](https://github.com/rerun/rerun/wiki)
for additional documentation including:

* [Getting started](https://github.com/rerun/rerun/wiki)
* [Installation](https://github.com/rerun/rerun/wiki/Installation)
* [Stubbs module tool](https://github.com/rerun/rerun/tree/master/modules/stubbs)
* [Why rerun?](https://github.com/rerun/rerun/wiki/Why-rerun%3F)

# OPTIONS

`-h`
: Print help and usage then exit.

`-M` *DIRECTORY*
: Module library directory path.

`-L` *DIRECTORY*
: Recorded _command_ execution logs stored in this directory. Also settable via `RERUN_LOGS`.

`-v` 
: Execute _command_ in verbose mode. 

`-V` 
: Execute `rerun` and _command_ in verbose mode. 


# USING

## Help

For command line syntax and example usage execute `rerun` using the `--help` flag:

	$ ./rerun --help
	 _ __ ___ _ __ _   _ _ __
	| '__/ _ \ '__| | | | '_ \ 
	| | |  __/ |  | |_| | | | |
	|_|  \___|_|   \__,_|_| |_|
	Version: v0.1. License: Apache 2.0.

	Usage: rerun [-h][-v][-V] [-M <dir>] [-L <dir>] [module:[command [options]]]

	Examples:
	| $ rerun 
	| => List all modules.
	| $ rerun freddy
	| => List all freddy commands.
	| $ rerun freddy:dance --jumps 3
	| => Execute the freddy:dance command.
	| $ rerun -M /var/rerun freddy:dance
	| => Execute the freddy:dance command found in /var/rerun


## Listing

Without arguments, `rerun` will list existing modules:

    $ rerun
      freddy: "A dancer in a red beret and matching suspenders"

To list the commands available from the 'freddy' module run:

    $ rerun freddy
     study: "tell freddy to study"
       --subject <math>: "the summer school subject"
     dance: "tell freddy to dance"
       --jumps <1>: "jump #num times"

The listing consists of info about command options 
including default values if they were described with option metadata.

Options that declare a default value are shown
with a string between the "<>" characters.

For example, notice how "--jumps" option shows `<1>`.
The "1" is the default value assigned to the "--jumps" option.

See the "Environment" section below to learn about the
`RERUN_MODULES` environment variable. This variable
specifies the directory where rerun modules exist.

### Bash completion

If you are a Bash shell user, be sure to source the `bash_completion.sh` file. 
It provides listing via the tab key.

Type `rerun` and then the tab key. The shell will generate
a list of existing modules.

    $ rerun[TAB][TAB]
    freddy

Rerun shows there is a module named "freddy" installed.

Typing the tab key again will show the commands inside the "freddy" module:

    $ rerun freddy: [TAB]
    dance  study     

In this case, two commands are found and listed. Press tab again
and choose a command.
After accepting a command, typing the tab key will show arguments.

    $ rerun freddy:study -[TAB]
    --subject

The `freddy:study` command accepts one option (--subject <>).
    
## Command execution

Commands are executed by stating the module,
command and possibly options. The basic usage form is
"`rerun` _module_:_command_ [_options_]".

To run the "study" command in the freddy module, type:

    $ rerun freddy:study
    studying (math)

The outputed string "studying (math)" is the printed result. 
In this example, "math" is the subject option's default value
as defined in the module metadata.
    
Command options are passed after the "module:command" string. 
Tell freddy to study the subject, "biology" by specifying 
the `--subject <>` option:

    $ rerun freddy:study --subject biology
    studying (biology)

If the 'freddy' module is stored in `/var/rerun`, then the command usage
would be:

    $ rerun -M /var/rerun freddy:study
    studying (math)

### Archives

An *archive* contains all the rerun modules you need
(you might have a library of them) and gives you
the same exact interface as rerun,... all in one file!

Specifically, an archive is a set of modules 
and `rerun` itself packaged into a self extracting
script (by default in a file named "rerun.bin"). 
Archives can be useful if you want
to share a single self contained executable that contains all the needed modules.

Run an archive script like you would run `rerun`.

You can execute an archive via `bash` like so:

    $ bash rerun.bin <module>:<command> --your options

If the execute bit is set, invoke the archive directly.

Here the archive is executed without arguments which causes the archive
to list the modules contained within it.

    $ ./rerun.bin
      freddy: "A dancer in a red beret and matching suspenders"
      .
      . listing output ommitted

Note, ".bin" is just a suffix naming convention for a self-extracting script.
The archive file can be named anything you wish.

Run the `freddy:dance` command in the archive:

	$ ./rerun.bin freddy:dance --jumps 3
	jumps (3)

See `stubbs:archive` for further information about creating and 
understanding rerun archives.


# LOGS

Rerun records command execution as replay logs, if the `-L <dir>` 
argument is set or the `RERUN_LOGS` environment variable is set.
Be sure to set `RERUN_LOGS` to a writable directory. 

Each command execution is recorded in the form of a "replay" log
file (ending with `.replay`).
This log file contains information about the command
execution, as well as, the output from the execution.

*File naming*

Each replay log is named using the following pattern:

    $RERUN_LOGS/$MODULE-$COMMAND-YYYY-MM-DD-THHMMSS-PID.replay

To list the replay logs for the `freddy:dance` command use `ls`:

	$ ls -l $RERUN_LOGS/freddy-dance*.replay
	-rw-rw----  1 alexh  wheel  188 Sep 21 19:54 freddy-dance-2011-09-21T195402-2344.replay
	

*File format*

Execution logs follow a simple format that combines 
command execution metadata and log output.

Log metadata:

* RERUN: The rerun executable
* MODULE: The module name
* COMMAND: The command name
* OPTIONS: The command options
* USER: The user executing the command
* DATE: The timestamp for the execution

Here's the metadata as specified in the file template:

	#
	# Rerun replay log
	#
	RERUN="$RERUN"
	MODULE="$MODULE"
	COMMAND="$COMMAND"
	OPTIONS="$*"
	USER="$USER"
	DATE="$(date '+%Y-%m%d-%H%M%S')"
	__COMMAND_OUT_BELOW__
	
Any command output is stored below the line delimiter, `__COMMAND_OUT_BELOW__`.

Here's an example replay file for the `freddy:dance` command:

	#
	# Rerun replay log
	#
	RERUN="/Users/alexh/rerun-workspace/rerun/rerun"
	MODULE="freddy"
	COMMAND="dance"
	OPTIONS=""
	USER="alexh"
	DATE="2011-0921-195402"
	__COMMAND_OUT_BELOW__

	jumps (1)

This simple shell function will parse the content for a given 
replay log:

	rerun_extractLog() {
		[ -f $1 ] || die "file does not exist: $1"
		SIZE=$(awk '/^__COMMAND_OUT_BELOW__/ {print NR + 1; exit 0; }' $1) || die "failed sizing output"
		tail -n+$SIZE $1 || die "failed extracting output"
	}

Running this shell function for a given replay log looks similar to this:

	$ rerun_extractLog $RERUN_LOGS/freddy-dance-2011-0921-194512.replay

	jumps (1)

# MODULES

## Layout

A rerun module assumes the following structure:

    <MODULE>
    ├── commands
    │   └── cmdA (directory for cmdA files)
    │       ├── metadata (command metadata)
    │       ├── options.sh (option parsing script)
    │       └── script (command script)
    ├── lib
    │   └── functions.sh (module function library)
    ├── metadata (module metadata)
    ├── options (module options)
    │   └── optyY ("optY" option)
    │       └── metadata (declares metadata for "optY" option)
    └── tests
        └── cmdA-1-test.sh (unit tests for cmdA)
    

## Command Scripts

Rerun's internal dispatch logic uses the directory layout
described above to find and execute scripts for each command.

Rerun expects an implementation script for each command.

* `script`: Script implementation.
* `options.sh`: Script to parse options (generated by stubbs for "bash" modules).

## Metadata

The metadata file format uses line separated _KEY=value_
pairs to define module attributes. The module metadata
file declares two properties:

* NAME: Declare name displayed to user.
* DESCRIPTION: Brief explanation of use.

For example, a module named `freddy` is named
and described in a file called `RERUN_MODULES/freddy/metadata`:

    NAME="freddy"
    DESCRIPTION="A dancer in a red beret and matching suspenders"

Command metadata is described in a file called
`RERUN_MODULES/<module>/commands/<command>/metadata`.
Here's the command metadata for the "study" command:

    NAME="study"
    DESCRIPTION="tell freddy to study"
    OPTIONS="subject"

Each command can have options assigned to it. The
example above shows that the "study" command has
an option called "subject".

Options are described in their own metadata files
following the naming convention:
`RERUN_MODULES/<module>/options/<option>/metadata`.
Beyond just NAME and DESCRIPTION, options can also declare:

* `ARGUMENTS`: Does the option take an argument.
* `REQUIRED`: Is the option required.
* `DEFAULT`: Sensible value for an option default 

Here's the metadata describing an option named "subject":

    NAME=subject
    DESCRIPTION="the summer school subject"
    ARGUMENTS=true
    REQUIRED=true
    DEFAULT=math

Combining the examples above into the layout described earlier
the "freddy" module along with its commands "dance" and "study"
are illustrated here:

    modules/freddy/
    ├── commands
    │   ├── dance
    │   │   ├── metadata
    │   │   ├── options.sh
    │   │   └── script
    │   └── study
    │       ├── metadata
    │       ├── options.sh
    │       └── script
    ├── lib
    │   └── functions.sh
    ├── metadata
    ├── options
    │   ├── jumps
    │   │   └── metadata
    │   └── subject
    │       └── metadata
    └── tests
        └── dance-1-test.sh


# ENVIRONMENT

`RERUN_MODULES`
: Path to directory containing rerun modules.
If RERUN_MODULES is not set, it is defaulted
relative to the location of the rerun executable.

`RERUN_LOGS`
: Path to directory where rerun will record command
executions.

`RERUN_COLOR`
: Set 'true' if you want ANSI text effects. Makes
labels in text to print bold in the console.
Syntax errors will also print bold.

`DIFF`
: Set to the particular `diff` command to use for
replay log comparisons.

# SEE ALSO

To create modules, see
[stubbs](https://github.com/rerun/rerun/tree/master/modules/stubbs).

# ERROR CODE

`0`
: All commands executed successfully.

`1`
: One or more commands failed.

`2`
: Option syntax error.

`127`
: Unknown error case.

# LICENSE

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
<https://github.com/rerun/rerun/>.
