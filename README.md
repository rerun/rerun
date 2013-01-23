# NAME

rerun - a modular shell automation framework to organize your keeper scripts.

# SYNOPSYS

	rerun [-h][-v][-V] [-M <dir>] [module:[command [options]]]

# DESCRIPTION

Rerun is a simple command runner that turns loose shell scripts
into modular automation. Rerun will help you
organize your scripts into well defined command interfaces.
Collections of management modules can be archived and delivered as
a single executable to facilitate team hand offs.
Using the "stubbs" module, rerun will even facilitate documentation
and unit tests.
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
	Version: 1.0.2. License: Apache 2.0.

	Usage: rerun [-h][-v][-V] [-M <dir>] [module:[command [options]]]


## Listing

Without arguments, `rerun` will list existing modules and 
their description and version:

    $ rerun
      stubbs: "Simple rerun module builder" - 1.0.2

To list the commands available in a module specify the module
name too. Here the commands are listed for the 'stubbs' module:

    $ rerun stubbs
     add-command: "add command to module"
         --command|-c <>: "the command name"
         --description <>: "the brief description"
         --module|-m <>: "the module name"
        [ --overwrite <false>]: "should overwrite?"
     add-module: "add a new module"
         --description <>: "the brief description"
         --module|-m <>: "the module name"
        [ --template <>]: "the template name or path"
        .
        . 
        .
        
The command listing includes the command description and
any options assigned to the command. 

Options that declare a default value are shown
with a string between the "<>" characters.

For example, notice how "--overwrite" option shows `<false>`.
The "false" is the default value assigned to the "--overwrite" option.

See the "Environment" section below to learn about the
`RERUN_MODULES` environment variable. This variable
specifies the directory where rerun modules exist.

### Bash completion

If you are a Bash shell user, be sure to source the `bash_completion.sh` file. 
It provides listing via the tab key.

Type `rerun` and then the tab key. The shell will generate
a list of existing modules.

    $ rerun[TAB][TAB]
    stubbs: 

Rerun shows the module "stubbs".

Typing the `s` character and the tab key again 
will show the commands inside the "stubbs" module:

    $ rerun stubbs: [TAB]
    add-command  add-module  add-option  archive  docs  edit  migrate  rm-option  test

Several commands are listed. Press tab again
and choose a command. You can specify the first few characters
and the command name will be completed, too.

After accepting a command, typing the tab key will list the command options.

    $ rerun stubbs: add-module -[TAB]
    --description  --module  --template

The `stubbs:add-module` command accepts three options 
(--description <> --module <> --template <>).
    
You can continue using command completion to cycle through
the remaining options. 
    
## Command execution

Commands are executed by stating the module,
command and any command options. The basic usage form is
"`rerun` _module_:_command_ [ _options_ ]".

To run the "archive" command in the stubbs module, type:

    $ rerun stubbs:archive
    Wrote self extracting archive script: /tmp/rerun.bin

Command options are passed after the "module:command" string. 
Run the "stubbs:archive" command but specify where the archive file is written.

    $ rerun stubbs:archive --modules waitfor --file $HOME/rerun.bin

If the 'stubbs' module is stored in `/var/rerun`, then the command usage
would be:

    $ rerun -M /var/rerun stubbs:archive

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
      waitfor: "utility commands that wait for a condition."
      .
      . listing output ommitted

Note, ".bin" is just a suffix naming convention for a self-extracting script.
The archive file can be named anything you wish.

Run the `waitfor:ping` command in the archive:

	$ ./rerun.bin waitfor:ping --server remoteserver

See `stubbs:archive` for further information about creating and 
understanding rerun archives.


# MODULES

## Layout

A rerun module assumes the following structure:

    <MODULE>
    |-- commands
    |-- `-- cmdA (directory for cmdA files)
    |--     |-- metadata (command metadata)
    |--     |-- options.sh (option parsing script)
    |--     `-- script (command script)
    |-- lib
    |-- `-- functions.sh (module function library)
    |-- metadata (module metadata)
    |-- options (module options)
    |   `-- optyY ("optY" option)
    |       `-- metadata (declares metadata for "optY" option)
    `-- tests
        `-- cmdA-1-test.sh (unit tests for cmdA)
    

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

* `NAME`: Declare name displayed to user.
* `DESCRIPTION`: Brief explanation of use.

For example, a module named `waitfor` is
declared in a file called `RERUN_MODULES/waitfor/metadata`:

    NAME="waitfor"
    DESCRIPTION="utility commands that wait for a condition."

Command metadata is described in a file called
`RERUN_MODULES/<module>/commands/<command>/metadata`.
It uses NAME and DESCRIPTION properties like a module but
adds, OPTIONS.

* `OPTIONS`: List of options assigned to the command.

Here's the command metadata for the "ping" command:

    NAME="ping"
    DESCRIPTION="wait for ping response from a host"
    OPTIONS="host interval"

Each command can have options assigned to it. The
example above shows that the "ping" command has
options called "host" and "interval".

Options are described in their own metadata files
following the naming convention:
`RERUN_MODULES/<module>/options/<option>/metadata`.
Beyond just `NAME` and `DESCRIPTION`, options can also declare:

* `ARGUMENTS`: Does the option take an argument.
* `REQUIRED`: Is the option required.
* `DEFAULT`: Sensible value for an option default 

Here's the metadata describing an option named "host":

    NAME=host
    DESCRIPTION="the server to reach"
    ARGUMENTS=true
    REQUIRED=true
    DEFAULT=

Combining the examples above into the layout described earlier
the "waitfor" module along with its command "ping"
are illustrated here:

    modules/waitfor/
    |-- commands
    |   `-- ping
    |       |-- metadata
    |       |-- options.sh
    |       `-- script
    |-- lib
    |   `-- functions.sh
    |-- metadata
    |-- options
    |   |-- jumps
    |   |   `-- metadata
    |   `-- subject
    |       `-- metadata
    `-- tests
        `-- ping-1-test.sh


# ENVIRONMENT

`RERUN_MODULES`
: Path to directory containing rerun modules.
If RERUN_MODULES is not set, it is defaulted
relative to the location of the rerun executable.

`RERUN_COLOR`
: Set 'true' if you want ANSI text effects. Makes
labels in text to print bold in the console.
Syntax errors will also print bold.

# VERSIONING

Rerun and its modules following the [Semantic Versioning Specification](http://semver.org). As a consequence, any backwards incompatible change to Rerun will result in its major version number being incremented. Module developers are expected to provide a version of their module compatible with each major version of Rerun.

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
