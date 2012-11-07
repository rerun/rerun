# Extending stubbs scripting language support

Rerun does not require modules written using
the same scripting language as itself.

Stubbs provides a model for extendable support to
write and execute modules written in interpreted
scripting languages. 

## Stubbs commands

Stubbs commands each play a role during module
development. 

Command responsibilities:
    
* `add-module`: Create an initial module structure and function library supporting scripting language.
* `add-command`: Create a command script using a template for the scripting language.
* `add-option`, `rm-option`: Generate options parsing code for command scripts written in scripting language and used by its command scripts.

## Interpreters

Rerun relies on an _interpreter_ to execute the command script.
An _interpreter_ is the executable runtime for a scripting 
language which reads the script file and processes it. 

Stubbs provides a structure to add an support multiple
scripting languages.

Each interpreter has a directory position under stubbs/lib. Eg:

    $RERUN_MODULES/stubbs/lib/interpreters/$INTERPRETER

Within this directory structure exists code generator,
templates and metadata needed by stubbs commands.

## Metadata

Each language support library contains metadata that describes
the necessary components assumed anb used by the stubbs commands.

Metadata properties:

* `RERUN_SCRIPT_INTERPRETER`: Interpeter name (eg, "bash", "python").
* `RERUN_FUNCTION_LIB`: Relative file name for the function library.
* `RERUN_COMMAND_SCRIPT`: Relative file name for the command script.
* `RERUN_OPTIONS_SCRIPT`: Relative file name for the options parser script.
* `RERUN_OPTIONS_GENERATOR`: Relative file name to the executable that generates the option parser script.

Example: stubbs/lib/bash/metadata

    RERUN_SCRIPT_INTERPRETER=bash
    RERUN_FUNCTION_LIB=functions.sh
    RERUN_COMMAND_SCRIPT=script
    RERUN_OPTIONS_SCRIPT=options.sh
    RERUN_OPTIONS_GENERATOR=generate-options

## Directory structure

Each language has a directory position under lib:

    $RERUN_MODULES/stubbs/lib/interpreters/$INTERPRETER
    
For example, the _bash_ interpreter library looks like so:

    stubbs/lib/interpreters/bash
    ├── generate-options
    ├── metadata
    └── templates
        ├── script
        └── functions.sh
       
## Option processing

Stubbs uses the intepreter library's `RERUN_OPTIONS_GENERATOR`
exeuctable to generate a command's options parser code.

The `RERUN_OPTIONS_GENERATOR` executable must support the following
usage pattern:

    usage: generate-options <directory> <module> <command>

Arguments:

* directory: Directory where modules reside.
* module: The module name.
* commands: The command name to create the option parser.

Output:

* The  `RERUN_OPTIONS_GENERATOR` executable must produce
its output to the stdout file channel. Stubbs will 
redirect the output where it needs it.

## Templates

Stubbs commands require template files during the module module
and command creation process.

* `RERUN_FUNCTION_LIB`: Base function library used by stubbs:add-module.
* `RERUN_COMMAND_SCRIPT`: Template command script used by stubbs:add-command.

### Script Headers

Stubbs commands re-write script headers to reflect 
options changes.

Templates for command scripts must have the following
header content.

    #!/usr/bin/env @INTERPRETER@
    #
    #/ command: @MODULE@:@COMMAND@: "@DESCRIPTION@"
    #
    #/ usage: rerun @MODULE@:@COMMAND@ [options]
    #
    #/ rerun env variables: RERUN, RERUN_VERSION, RERUN_MODULES, RERUN_MODULE_DIR
    #/ option variables: @VARIABLES@

Stubbs treats lines that begin with `#/` as
code, parses these lines and will substitute values contained in them.

### Tokens

The stubbs commands will filter and substitute values
for the following tokens:

* @INTERPRETER@: Replaced with interpreter name.
* @MODULE@: Replaced with module name.
* @COMMAND@: Replaced with command name.
* @DESCRIPTION@: Replaced with the description.
