# stubbs: A module and command set to create rerun modules

Use `stubbs` to define new *rerun* modules and commands.

Stubbs provides a small set of commands that 
help you define and organize modules according to
the *rerun* layout conventions and metadata format. 

Stubbs won't write your implementations for you but
it will help keep you between the guard rails!

## Commands

### add-module

Create a new rerun module.

*Usage*

    rerun stubbs:add-module [--module <>] [--description <>]
    
*Example*

Make a new module named "freddy":

    rerun stubbs:add-module --module freddy --description "A dancer in a red beret and matching suspenders"

The `add-module` command will print:

    Created module structure: /Users/alexh/.rerun/modules/freddy

### add-command

Create a command in the specified module and generate a default command script implementation.

*Usage*

    rerun stubbs:add-command --command <> --description <> --module <> [--ovewrite <false>]

*Example*

Add a command named "dance" to the freddy module:

    rerun stubbs:add-command --command dance --description "tell freddy to dance" --module freddy

The `add-command` module generates a boilerplate command script file you can edit.

	Wrote command test: /Users/alexh/.rerun/modules/freddy/tests/dance-1-test.sh
	Wrote command script: /Users/alexh/.rerun/modules/freddy/commands/dance/script

Of course, stubbs doesn't write the implementation for you, merely a _stub_.

See the "Command implementation" section below to learn about 
the `script` command script.

See the *Testing* section below to learn about
the test script.

### add-option

Define a command option for the specified module and generate options parser script.

*Usage*

    rerun stubbs:add-option [--arg <true>] --option <> --description <> --module <> --command <> [--required <false>]

*Example*

Define an option named "--jumps":

    rerun stubbs:add-option --option jumps --description "jump #num times" --module freddy --command dance

You will see output similar to:

    Created option: /Users/alexh/.rerun/modules/freddy/options/jumps/metadata

Besides the `options/jumps/metadata` file, `add-option` also generates an
option parsing script: `$RERUN_MODULES/$MODULE/commands/$COMMAND/options.sh`.

The `script` script sources the `options.sh` script to take care of
command line option parsing.

Users will now be able to specify a "--jumps" argument to the `freddy:dance` command:

    $ rerun freddy
    freddy:
     dance: tell freddy to dance
        --jumps <>: "jump #num times"

### archive

The `archive` command will produce
a bash self extracting archive script (aka. a .bin file)
useful for launching a self contained rerun environment.

Use `stubbs:archive` to save a set of specified modules and
the `rerun` executable into a single file that can easily
be copied across the network.

`archive` generates a script that takes the same argument
list as `rerun`. This generated script basically acts
like a `rerun` launcher.

*Usage*

    rerun stubbs:archive [--file <>] [--modules <"*">] [--version <>]

*Example*

Create an archive containing the "freddy" module:

    rerun stubbs:archive --modules "freddy"

The `archive` command generates a "rerun.bin" file 
in the current directory.

Run the self extracting archive script without options and you
will see freddy's commands listed:

    $ bash rerun.bin
    freddy:
     dance: tell freddy to dance
        --jumps <>: "jump #num times"

Now run the `freddy:dance` command.

    $ bash rerun.bin freddy:dance --jumps 10
    jumps (10)

It works like a normal `rerun` command. Amazing !

*Internal details*

The archive format is a base64 encoded gzip'd tar file appended to a bash shell script
(e.g., cat EXTRACTSCRIPT PAYLOAD.tgz.base64 > RERUN.BIN).

The tar file contains payload content, specifically rerun and modules.

When the archive file is executed, 
the shell script reads the binary "attachment",
decompresses and unarchives the payload and then invokes
the rerun launcher.

The rerun launcher creates an ephemeral workspace to load
the included modules and then executes the included `rerun`
executable in the user's current working directory.

Refer to the source code implementation for further details.

### docs

Generate the docs.

*Usage*

    rerun stubbs:docs --module <>
    
*Example*

Generate the manual page for "freddy" module:

    rerun stubbs:docs --module freddy

The `docs` command will print:

    Generated unix manual: /Users/alexh/rerun-workspace/rerun/modules/freddy/freddy.1


Run `rerun --manual <module>` to display it:
	
	rerun --manual freddy
	
### test

Run module test suite. 

*Usage*

    rerun stubbs:test [--module <>] [--command <>] 
    
*Example*

Run the test suite for the module named "freddy":

    rerun stubbs:test --module freddy

The `test` command will print output similar to the following:

    =========================================================
     Module: freddy 
    =========================================================
    freddy:dance
      it_runs_without_arguments:                       [PASS]
    =========================================================
    Tests:    1 | Passed:   1 | Failed:   0

Each command that has any unit test scripts will be tested.

See the "Testing" section below to learn about
how to define tests for your module.

## Command scripts

Running `stubbs:add-command` as shown above will generate a stub
script implementation for the new command: 
`$RERUN_MODULES/$MODULE/commands/$COMMAND/script`:

The "dance" command's `script` file is shown below.

File listing: `$RERUN_MODULES/freddy/commands/dance/script`

    #!/usr/bin/env bash
    #
    # NAME
    #
    #   dance 
    #
    # DESCRIPTION
    #
    #   tell freddy to dance
     
    # Function to print error message and exit
    rerun_die() {
        echo "ERROR: $* " ; exit 1;
    }
     
    # Parse the command options     
    [ -r $RERUN_MODULES/freddy/commands/dance/options.sh ] && {
       . $RERUN_MODULES/freddy/commands/dance/options.sh
    } 
     
    # Exit immediately upon non-zero exit. See [set](http://ss64.com/bash/set.html)
    set -e
     
    # ------------------------------
    # Your implementation goes here.
    # ------------------------------
     
    exit $?

The name and description supplied via `add-command` options
are inserted as comments at the top.

A `rerun_die` function is provided for convenience in case things go awry.

Rather than implement a specialized option parser logic inside
each command implementation, `add-option` generates a reusable
script sourced by the command  script.
When your command is run, all options and their arguments 
are parsed by the options.sh script and returned as shell
variables to your command script.

Naturally, your implementation code goes between the rows
of dashes. 
For this example, insert `echo "jumps ($JUMPS)` as a trivial
implementation:

    # ------------------------------
    echo "jumps ($JUMPS)"
    # ------------------------------
    
    exit $?

Always faithfully check and return useful exit codes!

Try running the `freddy:dance` command:

    $ rerun freddy:dance --jumps 3
    jumps (3)

The "jumps (3)" is written to the console standard output.

Run `freddy:dance` again but this time without options.

    $ rerun freddy:dance
    jumps ()

This time an empty pair of parenthesis is printed.
The problem is this: the `$JUMPS` variable was not set
so an empty string is printed instead.
    
### Option defaults

If a command option is not supplied by the user, the
`options.sh` script (created by `add-option`) 
can set a default value.

Call the `add-option` command again but this
time use its `--default <>` parameter to set the default value. 

Here the "--jumps" option is set to a default value, "1":

    rerun stubbs:add-option \
      --option jumps -description "jump #num times" --module freddy --command dance \
      --default 1

The `add-option` will update the `jumps` option metadata file with the
new default value and extend the `options.sh` script.

Run the `freddy:dance` command again but this time without the "--jumps" option:

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
the "--jumps" option and the `JUMPS` variable that will be set
to the value of the "--jumps" argument.

    # generated by add-option
    # Tue Sep 13 20:11:52 PDT 2011
     
    # print error message and exit non-zero
    rerun_option_usage() {
        echo "$USAGE" >&2 ; exit 2;
    }
    # check option has its argument
    rerun_option_check() {
        [ "$1" -lt 2 ] && syntax_error
    }
     
    # options: [jumps]
    while [ "$#" -gt 0 ]; do
        OPT="$1"
        case "$OPT" in
            -j|--jumps) rerun_option_check $# ; JUMPS=$2 ; shift ;;
            # unknown option
            -?)
                rerun_option_usage
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
away from the command implementation logic in `script`, facilitates
additional options being created. It also helps "stubbs"
preserve changes you make to `script` or other scripts
that source `options.sh`.

### Verbosity?

What happens when your command script fails and
all you see is one line of cryptic error text?
Shed more light by enabling verbose output using rerun's `-v` flag.

Adding '-v' effectively has `rerun` call the command
script using bash's "-vx" flags. 

Here's a snippet of the `freddy:dance` command with verbose output:

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

### Example: freddy

This section describes how to define the "freddy" module used
through the documentation.

Create the "freddy" module:

	rerun stubbs:add-module --module freddy --description "A dancer in a red beret and matching suspenders"

Create the `freddy:study` command:

	rerun stubbs:add-command --command study \
	   --description "tell freddy to study" --module freddy

Define an option called "--subject":

	rerun stubbs:add-option --option subject \
	   --description "subject to study" --module freddy --command study \
	   --default math --required false

Edit the default implementation (`$RERUN_MODULES/freddy/commands/study/script`).
The implementation should echo what freddy is studying:

	# ------------------------------
	echo "studying ($SUBJECT)"
	# ------------------------------

Similarly, define the `freddy:dance` command:

	rerun stubbs:add-command --command dance \
		   --description "tell freddy to dance" --module freddy

Define an option called "--jumps":

	rerun stubbs:add-option --option jumps \
		   --description "jump #num times" --module freddy --command dance \
		   --default 1 --required false

Edit the default implementation (`$RERUN_MODULES/freddy/commands/dance/script`).
The implementation should echo how many jumps:

	# ------------------------------
	echo "jumps ($JUMPS)"
	# ------------------------------

The freddy commands, their options and default implementations are completed.
Use rerun listing to show the command usage:

	$ rerun freddy
	 dance: "tell freddy to dance"
	    [-j|--jumps <1>: "jump #num times"]
	 study: "tell freddy to study"
	    [-s|--subject <math>: "subject to study"]

The "dance" and "study" commands are listed. 
Try `freddy:study` with and without options.
Since a default value was assigned to "--subject"
(remember "--default math" was specified to `stubbs:add-option`),
the subject "math" will be printed.

Without option:

	$ rerun freddy: study
	studying (math)

With option:

	$ rerun freddy: study --subject locking
	studying (locking)

## Testing 

Stubbs provides basic support for unit testing modules through
the use of [roundup](http://bmizerany.github.com/roundup/).
Stubbs bundles roundup, so it's not necessary to create
a global install (unless you want to in which case you should!).
Each module can contain a test suite of scripts.
Stubbs runs module tests via the `stubbs:test` command.

Here the unit tests for the "freddy" module are executed via `stubbs:test`:

	rerun stubbs:test --module freddy

A successful unit test will print `PASS` while a failed one 
will print `FAIL` and cause rerun to exit non zero.

Stubbs creates a unit test for every command that is created
through `stubbs:add-command`.
When `add-command` is run, a boiler plate unit test script
is generated and added to the module's test suite.

Below is a partial view of "freddy" module files. Notice
how the `tests` directory contains files named after
each command and ends with the suffix "-test.sh".

    modules/freddy/
    ├── commands
    │   └── dance
    │       ├── metadata
    │       ├── options.sh
    │       └── script
    ├── lib
    │   └── functions.sh
    ├── metadata
    ├── options
    │   └── jumps
    │       └── metadata
    └── tests
        └── dance-1-test.sh

To run the test suite for a single command use the `--command <>` option:

	rerun stubbs:test --module freddy --command dance

This will cause roundup to run any tests named "dance-*-test.sh".

### Tests scripts

A *roundup* test-plan is a simple script that contains 
functions whose names are prefixed with `it_`.
Roundup will extract these function names and run
them in a sandbox.
Tests should return with a 0 (zero) 
upon successful test validation. Non-zero
causes the test to fail.

The implementation of the individual test scripts 
are completely open to anything the author wishes
to do. 

Here's an example script that began as a boiler
plate generated by `add-command`. Notice how
this script contains several rough sections:

1.  Helper function definitions
2.  The plan description
3.  Test function

File listing: `$RERUN_MODULES/freddy/tests/dance-1-test.sh`

    #!/usr/bin/env roundup
    #
    # This file contains test scripts to run for the dance command.
    # Execute it by invoking: 
    #    
    #     rerun stubbs:test -m freddy -c dance
    #
    # Helpers
    # ------------
    
    rerun() {
        command $RERUN -M $RERUN_MODULES "$@"
    }
    
    # The Plan
    # --------

    describe "freddy:dance"

    it_runs_without_arguments() {
        test "$(rerun freddy:dance)" = "jumps (1)"
    }
 
If  setup and tear down procedures are needed, create a 
`before` and/or `after` function. These will be run
before and after each test in the plan.

 See the 
[test](http://ss64.com/bash/test.html) and
[expr](http://ss64.com/bash/expr.html) commands
to declare assertions.

It's also possible to execute this test directly via `roundup`.

	$ ( cd $RERUN_MODULES/freddy/tests ; roundup dance-1-test.sh )


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
