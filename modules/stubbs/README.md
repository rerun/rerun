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

    rerun stubbs:add-module [-name <>] [-description <>]
    
*Example*

Make a new module named "freddy":

    rerun stubbs:add-module -name freddy -description "A dancer in a red beret and matching suspenders"

The `add-module` command will print:

    Created module structure: /Users/alexh/.rerun/modules/freddy

### add-command

Create a command in the specified module and generate a default implementation.

*Usage*

    rerun stubbs:add-command -name <> -description <> -module <> [-ovewrite <false>]

*Example*

Add a command named "dance" to the freddy module:

    rerun stubbs:add-command -name dance -description "tell freddy to dance" -module freddy

The `add-command `module will generate a boilerplate script you can edit.

	Wrote command test: /Users/alexh/.rerun/modules/freddy/tests/commands/dance/default.sh
	Wrote command script: /Users/alexh/.rerun/modules/freddy/commands/dance/default.sh

Of course, stubbs doesn't write the implementation for you, merely a stub.

See the "Command implementation" section below to learn about 
the `default.sh` script.

See the "Testing" section below to learn about
the `test.sh` script.

### add-option

Define a command option for the specified module and generate options parser script.

*Usage*

    rerun stubbs:add-option [-arg <true>] -name <> -description <> -module <> -command <> [-required <false>]

*Example*

Define an option named "jumps":

    rerun stubbs:add-option -name jumps -description "jump #num times" -module freddy -command dance

You will see output similar to:

    Created option: /Users/alexh/.rerun/modules/freddy/commands/dance/jumps.option

Besides the `jumps.option` file, `add-option` also generates an
option parsing script: `$RERUN_MODULES/$MODULE/commands/$COMMAND/options.sh`.

The `default.sh` script sources the `options.sh` script to take care of
command line option parsing.

Users will now be able to specify a "-jumps" argument to freddy's "dance" command:

    $ rerun freddy
    freddy:
    [commands]
     dance: tell freddy to dance
      [options]
        -jumps <>: "jump #num times"

### archive

Create a bash self extracting archive script (aka. a .bin file)
useful for launching a self contained rerun environment.
Use `archive` to save a set of specified modules and
the `rerun` executable into a single file that can easily
be copied across the network.

`archive` generates a script that takes the same argument
list as `rerun`. This generated script basically acts
like a `rerun` launcher.

*Usage*

    rerun stubbs:archive [-file <>] [-modules <"*">]

*Example*

Create an archive containing the "freddy" module:

    rerun stubbs:archive -modules "freddy"

The `archive` command generates a "rerun.bin" script 
in the current directory.

Run the self extracting archive script without options and you
will see freddy's command listed:

    $ bash rerun.bin
    freddy:
    [commands]
     dance: tell freddy to dance
      [options]
        -jumps <>: "jump #num times"

Now run freddy's "dance" command.

    $ bash rerun.bin freddy:dance -jumps 10
    jumps (10)

It works like a normal `rerun` command. Amazing !

*Internal details*

The archive format is a gzip'd tar file appended to a bash shell script
(e.g., cat EXTRACTSCRIPT PAYLOAD.TGZ > RERUN.BIN).

The tar file contains payload content, specifically rerun and modules.

When the archive file is executed, 
the shell script reads the binary "attachment",
decompresses and unarchives the payload and then invokes
the rerun launcher.

The rerun launcher creates an ephemeral workspace to load
the included modules and then executes the included `rerun`
executable in the user's current working directory.

Refer to the source code implementation for further details.

### test

Run module test suite

*Usage*

    rerun stubbs:test [-name <>]
    
*Example*

Run the test suite for the module named "freddy":

    rerun stubbs:test -name freddy

The `test` command will print output similar to the following:

	[tests]  
	  dance: "test freddy dance": default.sh: OK

Each command that has any unit test scripts will be tested.

See the "Testing" section below to learn about
the test framework.

## Command implementation

Running `add-command` as shown above will generate a stub default implementation
for the new command: `$RERUN_MODULES/$MODULE/commands/$COMMAND/default.sh`:

The dance command's `default.sh` stub is shown below.

File listing: `$RERUN_MODULES/freddy/commands/dance/default.sh`

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

    $ rerun freddy:dance -jumps 3
    jumps (3)

The "jumps (3)" is written to the console stdout.

Run "dance" again but this time without options.

    $ rerun freddy:dance
    jumps ()

This time an empty pair of parenthesis is printed.
The problem is this: the `$JUMPS` variable was not set
so an empty string is printed instead.
    
### Option defaults

If a command option is not supplied by the user, the
`option.sh` script (created by `add-option`) 
can set a default value.

Call the `add-option` command again but this
time use its `-default <>` parameter to set the default value. 

Here the "jumps" option is set to a default value, "1":

    rerun stubbs:add-option \
      -name jumps -description "jump #num times" -module freddy -command dance \
      -default 1

The `add-option` will update the `jumps.option` metadata file with the
new default value and extend the `options.sh` script.

Run the "dance" command again but this time without the "-jumps" option:

    $ rerun freddy:dance
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
    [ -z "$JUMPS" ] && JUMPS=1 
     
Below the `while` loop, you can see a test for the
JUMPS variable (check for empty string).
A statement like this is added for options that declare 
`DEFAULT` metadata.

Separating options processing into the `options.sh` script,
away from the command implementation logic in `default.sh`, facilates
additonal options being created. It also helps "stubbs"
preserve changes you make to `default.sh` or other scripts
that source `options.sh`.

### OS specific command implementations

Your command's `default.sh` implementation may not work in all operating
system environments due to command and/or syntax differences.

Rerun will look for an operating system specific 
command implementation and run it instead, if it exists.

Effectively, rerun checks for a file named: 
`$MODULE/commands/$COMMAND/$(uname -s).sh`

For example, run `uname -s` on a centos host to see the name of the
operating system. It returns "Linux".

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

     echo "I'm a locker"
     
Run freddy's "dance" command:

    $ rerun freddy:dance
    I'm a locker

The result comes from rerun's execution of the new `Linux.sh` script.

### Verbosity?

What happens when your command implementation fails and
all you see is one line of cryptic error text?
Shed more light by enabling verbose output using rerun's `-v` flag.

Adding '-v' effectively has `rerun` call the command
implementation script with bash's "-vx" flags. 

Here's a snippet of freddy's "dance" command with verbose output:

    rerun -v freddy:dance
    .
    . <spipping out most of the verbose output ... >
    .
    # ------------------------------
    echo "jumps ($JUMPS)"
    + echo 'jumps (3)'
    jumps (3)
    # ------------------------------
    exit $?
    + exit 0

## Testing 

Stubbs provides very basic support for unit testing modules.
Each module can contain a test suite of scripts.
Stubbs will run a module's tests via the `test` command.

Here the unit tests for the "freddy" module are executed via `test`:

	rerun stubbs:test -name freddy
	[tests]  
	  dance: "test freddy dance": default.sh: OK

A successful unit test will print `OK` while a failed one 
will print `FAIL` and cause rerun to exit non zero.

Stubbs creates a unit test for every command that is created
through `add-command`.
When `add-command` is run, a boiler plate unit test script
is generated and added to the module's test suite.

Below is a partial view of "freddy" module files. Notice
how the `tests` directory closely parallels the `commands`
directory.

If the contents of the `tests` directory remind you
of a rerun module structure, you would be correct!
Rerun test suites are based on rerun modules themselves.

	modules/freddy
	├── commands
	│   └── dance
	│       ├── default.sh
	│       ├── jumps.option
	│       ├── metadata
	│       └── options.sh
	├── etc
	├── metadata
	└── tests
	    ├── commands
	    │   └── dance
	    │       ├── default.sh
	    │       └── metadata
	    └── metadata

You can see this by listing the unit tests in the suite.
Below you see the `-M <dir>` option used to
specify the freddy module directory as the modules directory:
	
	$ rerun -M $RERUN_MODULES/freddy tests
	[commands]
	 dance: "test freddy dance"
	  [options]

This example shows there is one unit test in the 
freddy test suite.

### Test logs

The output from the test script execution is stored in
the directory specified by `-logs <>` option or it will
defaulted to `$(pwd)/tests-reports`.

Here's a sample report listing of a test suite execution.

	test-reports
	├── TEST-freddy.txt
	├── TEST-freddy:dance.default.sh.txt
	├── TEST-freddy:dance.default.sh.txt.stderr
	├── TEST-freddy:dance.txt
	├── freddy-dance-2011-0921-194512.log
	└── tests-dance-2011-0921-194511.log

Cat the file named TEST-$MODULE.txt to see a summary:

	$ cat test-reports/TEST-freddy.txt 
	Testsuite: freddy
	Tests run: 1, Failures: 0, Time elapsed: 1 s

### Tests scripts

Test scripts should return with a 0 (zero) exit 
status upon successful test validation.

The implementation of the individual test scripts 
are completely open to anything the author wishes
to do. 

That said, it is possible to further leverage rerun
to facilitate testing.

Here's an example script that began as a boiler
plate generated by `add-command`. Notice how
this script contains several rough sections:

1.  Command metadata is stored at the top
2.  Extract execution log content
3.  Diff results to required example output
4.  Required example command output found below the `__LOG_BELOW__` string.

File listing: `$RERUN_MODULES/freddy/tests/dance/commands/default.sh`

	# This is a rerun command unit test script
	# 
	# metadata
	MODULE="freddy"
	COMMAND="dance"
	OPTIONS="$*"
	RERUN_MODULES=$HOME/rerun-workspace/rerun/modules
	# die - print an error and exit
	die() { echo "ERROR: $* " ; exit 1 ; }

	# Extract execution log content
	TMPDIR=$(mktemp -d /tmp/rerun.tests.XXXXXX) || die; # save it here
	SIZE=$(awk '/^__LOG_BELOW__/ {print NR + 1; exit 0; }' $0) || die "failed sizing test log"
	tail -n+$SIZE $0 > $TMPDIR/$(basename $0) || die "failed extracting test log"

	# Execute the command
	${RERUN:=rerun} -M $RERUN_MODULES ${MODULE}:${COMMAND} $OPTIONS 2>&1 | tee $TMPDIR/$$.log || die
	# Compare the results
	diff $TMPDIR/$(basename $0) $TMPDIR/$$.log

	exit $? ; # exit before reading the log content
	__LOG_BELOW__
	jumps (1)

The text below the `__LOG_BELOW__`	 delimiter should be
the example content the test results should match.
In this case, the expected text is "jumps (1)".

It's also possible to execute this test script directly.

	$ bash $RERUN_MODULES/freddy/tests/commands/dance/default.sh 
	jumps (1)	