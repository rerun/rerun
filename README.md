% RERUN(1) RERUN User Manual | 1.4.x


# NAME

rerun - a modular shell automation framework to organize your keeper scripts.

# SYNOPSIS

	rerun [-h][-v][-V] [-M <dir>] [--loglevel <>] [module:[command [options]]]

# DESCRIPTION

Rerun is a simple framework that turns loose shell scripts
into modular automation. Rerun will help you
organize your scripts into user friendly commands.
Collections of rerun modules can be archived and delivered as
a single executable or as RPMs or Debian packages to facilitate handoffs between teams.
The included "stubbs" module, helps you develop your own rerun modules,
generating option parsing code, documentation even unit tests for each of your commands.

End users can browse and execute commands via its two modes of operation:

1. *Listing*: Rerun lists modules and commands. Listing
information includes name, description and command line usage syntax.
2. *Execution*: Rerun provides option processing (possibly defaulting
unspecified arguments) and executes a script for the specified module command.

For the module developer, rerun is a trivial framework following
simple conventions that easily fit in a shell environment.
The "stubbs"  module development tool
helps create and enhance your rerun modules. Stubbs contains
commands to generate option processing code, metadata definition,
execute unit tests and generate documentation.

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

`--loglevel` *level*
: Set the default log level (debug info warn error fatal). See rerun_log API.

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
	Version: 1.4.x. License: Apache 2.0.

	Usage: rerun [-h][-v][-V] [-M <dir>] [module:[command [options]]]


## Listing

Without arguments, `rerun` will list existing modules and
their description and version:

    $ rerun
      stubbs: "Simple rerun module builder" - 1.1.2

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
specifies the directory/ies where rerun modules exist.

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
    Wrote self extracting archive script: /tmp/rerun.sh

Command options are passed after the "module:command" string.
Run the "stubbs:archive" command but specify where the archive file is written.

    $ rerun stubbs:archive --modules waitfor --file $HOME/rerun.sh

If modules are stored in `/var/rerun`, then the command usage
would be:

    $ rerun -M /var/rerun stubbs:archive

You can also declare the `RERUN_MODULES` environment variable to sepcify the modules directory path.

### Archives

After arching your rerun modules, you get a single executable file
containing a copy of rerun and one or more modules
(you might have a library of them). The archive uses
the same exact interface as rerun,... all in one file!

Specifically, an archive is a set of modules
and `rerun` itself packaged into a self extracting
script (by default in a file named "rerun.sh").
Archives can be useful if you want
to share a single self contained executable that contains all the needed modules.

Run an archive script like you would run `rerun`.

You can execute an archive via `bash` like so:

    $ rerun.sh <module>:<command> --your options

If the execute bit is not set, invoke the archive using bash (e.g., `bash rerun.sh <module>:<command>`).

When the archive is executed without arguments you get module and command listings:

    $ ./rerun.sh
      waitfor: "utility commands that wait for a condition."
      .
      . listing output ommitted

Note, ".sh" is just a suffix naming convention for a self-extracting script.
The archive file can be named anything you wish.

Run the `waitfor:ping` command in the archive:

	$ ./rerun.sh waitfor:ping --server remoteserver

*Archive special options*

Shell archives can be executed using special parameters of its own.
Below is a list of these optional arguments:

* `--archive-version-release`: Print the archive version and release info and exit.
* `--extract-only|-N <>`: Extract the archive to the specified directory and exit.
* `--extract-dir|-D <>`: Extract the archive  to the specified directory and then execute the specified command. By default, the `TMPDIR` environment variable is used to create a directory to extract the archive.

Besies the self extractive archive format, stubbs can also generate RPM and Debian packages.
See `stubbs:archive` for further information about creating and
understanding rerun archives.



# MODULES

## Layout

A rerun module assumes the following structure:

    <MODULE>
    |-- commands
    |-- `-- cmdA (each command gets its own subdirectory)
    |--     |-- metadata   (command metadata containing name, description and options uses)
    |--     |-- options.sh (option parsing script)
    |--     `-- script     (script implementing the command)
    |-- lib
    |-- `-- functions.sh (module function library)
    |-- metadata (module metadata)
    |-- options  (module options)
    |   `-- optyY ("optY" option)
    |       `-- metadata (declares metadata for "optY" option)
    `-- tests
        `-- cmdA-1-test.sh (unit tests for cmdA)

The "stubbs" module creates this directory structure for you but once you know
the conventions you can create and edit these files directly (if you prefer).

## Command Execution

Rerun's internal dispatch logic uses the directory and file convention
described above to find and execute scripts for each command.

Once the user specifies the module and command to execute, rerun finds the
command's script and executes it.

## Command Line Arguments

Optionally, additional the remaining command line may be accessed via the `_CMD_LINE` environment variable.  This may be used in the command's script if required.

For example, assume you have a command which sets up and runs an ubuntu Docker image and maps `./subdirectory` in as the `/opt` directory within the container.  Your module name is `docker` and your command is `run-ubuntu`.  You have defined a required option named `dir` that specifies which directory to map into the container.

In your `modules/docker/commands/run-ubuntu/script`, you implement your script as follows:

    CMD_LINE=${_CMD_LINE:-bash}
    IMAGE="ubuntu:16.04"
    HOME="-v $(pwd)/$DIR:/opt"
    PARAMS="-it -a stdin -a stdout -u 1000"
    docker run $PARAMS $HOME $IMAGE $CMD_LINE

If your rerun command line were:

    rerun docker:run-ubuntu --dir subdirectory/ ls -l

This will effectively run:

    docker run -it -a stdin -a stdout -u 1000 -v /home/me/subdirectory:/opt ubuntu:16.04 ls -l

(assuming you are currently in the /home/me directory)

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

# API

The rerun executable is also a sourceable file containing a number of public functions
useful in your modules. Read the rerun source file for the inline documentation.

Using stubbs:add-command to add commands to your module will already
take care of sourcing the rerun file for you.

To source rerun yourself, simply "dot" the file:

    . $(which rerun)

## Exit on error

The `rerun_die` function will print a message and exit.

    rerun_die "hit a nasty problem."

The default exit code is "1". You can specify another code:

    rerun_die 3 "exiting this program with exit code 3"

## Listing

A number of functions are useful for listing modules, commands and options.

* `rerun_modules directory` - list the modules in the directory
* `rerun_commands directory module` - List the commands for the specified module.
* `rerun_options directory module command` - List the options assigned to command.
* `rerun_module_options directory module` - List the options for the specified module

## Logging

The `rerun_log` function provides an API to standard logging functions.
If you would like to standardize how you write messages to the console or
to a logfile (or syslog), consider `rerun_log`.

The `rerun_log` function can perform a variety of actions but the default
one is to log a message to the configured (or default) log level.

    rerun_log "this is my message text"

On the console, the user would see:

    [info] : this is my message text

The default message level is "info".

The rerun_log function can perform a number of actions:

* `fmt-console ?format-string?` - set or get the message format printed to console.  Default: `[%level%] %command%: %message%`
* `fmt-logfile ?format-string?` - set or get the message format printed to logfiles. Default `[%tstamp%] [%level%] %command%: %message%`
    * Message format strings support the following tokens:
        - %tstamp%: Date-timestamp (i.e., `+%Y-%m-%dT%H%M%S-%Z`)
        - %level%: The message level.
        - %command%: The command context (formatted as: module:command).
        - %message%: The message text.
* `levels` - print the supported log levels. (eg, debug info warn error fatal)
* `level ?level?` - set or get the current log level.
* `log priority message` - write the message to the log at the specified priority.
* `logfile ?path?` - set or get the current log file to write messages.
* `syslog ?facility?` - set or get the current syslog facility. Set it to empty disables syslog.

To list the set of supported log levels use the `levels` action:

    rerun_log levels
    debug info warn error fatal

To find out the currently set log level use the `level` action:

    rerun_log level
    info

Messages will only be logged if the level is the same or greater than the current level.
You can set it to another level to control what messages are produced.

    rerun_log level error

Now only messages of error or fatal will be produced. Invalid log levels are ignored.

To write a message to a particular level, just specify it. Here's an info level message:

    rerun_log info "here is an info message"

To write an error level message, use "error" action:

    rerun_log error "here is an error message"

Messages of error or fatal level are written to stderr.

Log messages can also be written to a log file by specifying one via
the `logfile` action.

    rerun_log logfile my.log
    rerun_log warn "here is a warning message"

Use the `cat` command to see the log messages:

    cat my.log
    [2013-09-12T121553-PDT] [warn] : here is a warning message

Notice the the logfile also includes a timestamp before the level name.
To stop messages being written to the log file, set it to "" (empty string):

    rerun_log logfile ""

Messages can also be directed to syslog by assigning a syslog facility via `syslog` action.

    rerun_log syslog "local3"

Messages produced by rerun_log will directed to the local3.{level} priority.

    rerun_log info "here is a message also visible in syslog"

On my system this is visible in /var/log/messages:

    Sep 12 09:59:28 Targa.local alexh (rerun)[92715]: here is a message also visible in syslog

Be sure to specify a valid syslog facility name or you will get an error.

Typically, the rerun_log function is called from inside a command script.
The module and command name will be read from the executing context and included
as part of the standard message. Imagine a command `hello:say --msg HI` that logs
its message:

    rerun_log info "the message is '$MSG'"

The user would see the following message on the console:

    [info] hello:say: the message is 'HI'


# ENVIRONMENT

`RERUN_MODULES`
: Path to directories containing rerun modules.
If RERUN_MODULES is not set, it is defaulted
relative to the location of the rerun executable.
Multiple directories can be specified separated by a ':' (like $PATH).

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
