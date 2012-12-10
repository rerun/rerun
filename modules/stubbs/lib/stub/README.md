_Status_: Deprecated.

# Extending stubbs module creation.

Stubbs provides a means to
create modules supporting different styles of
implementation.

## Stubbs commands

There are four primary commands that play a role during the
course of module development. 

Command responsibilities:
    
* `add-module`: Create an initial module structure and function library supporting module commands.
* `add-command`: Create a command script using a template.
* `add-option`, `rm-option`: Generate options parsing code for command scripts.

## Stubs

A _stub_ provides the skeleton to
initialize a new module, create command scripts, and generate
option parsers.
One might liken a "stub" to a prototype from which
modules are based.

Each stub has a directory position under stubbs/lib/stub. 
Eg:

    $RERUN_MODULES/stubbs/lib/stub/$STUB

Within this directory structure exists code generator,
templates and metadata needed by stubbs commands.

### Metadata

Each stub contains metadata describing
the necessary components assumed and used by the stubbs commands.

Metadata properties:

* `NAME`: Stub name (eg, "bash").
* `TEMPLATE_FUNCTION_LIB`: The function library template.
* `TEMPLATE_COMMAND_SCRIPT`: The command script template.
* `OPTIONS_SCRIPT`: The options parser file name.
* `OPTIONS_GENERATOR`: Executable that generates the option parser script.

Example: stubbs/lib/stub/bash/metadata

    NAME=bash
    TEMPLATE_FUNCTION_LIB=templates/functions.sh
    TEMPLATE_COMMAND_SCRIPT=templates/script
    OPTIONS_SCRIPT=options.sh
    OPTIONS_GENERATOR=generate-options

### Directory structure

Each stub has a directory position under lib:

    $RERUN_MODULES/stubbs/lib/stub/$STUB
    
For example, the "bash" stub looks like so:

    stubbs/lib/stub/bash
    ├── generate-options
    ├── metadata
    └── templates
        ├── script
        └── functions.sh
       
## Option processing

The stubbs add-/rm-option commands use the
`OPTIONS_GENERATOR` exeuctable to 
generate a command's options parser code.

The `OPTIONS_GENERATOR` executable must support the following
usage pattern:

    usage: generate-options <directory> <module> <command>

Arguments:

* directory: Directory where modules reside.
* module: The module name.
* commands: The command name to create the option parser.

Output:

* The  `OPTIONS_GENERATOR` executable must produce
its output to the stdout file channel. Stubbs will 
redirect the output where it needs it.

## Templates

Stubbs commands require template files during the module
and command creation process.

* `TEMPLATE_FUNCTION_LIB`: Base function library used by stubbs:add-module.
* `TEMPLATE_COMMAND_SCRIPT`: Template command script used by stubbs:add-command.

### Script Headers

Stubbs commands re-write script headers to reflect 
options changes.

Templates for command scripts must have the following
header content.

    #!/usr/bin/env @SHELL@
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

* `@SHELL@`: Replaced with stub name.
* `@MODULE@`: Replaced with module name.
* `@COMMAND@`: Replaced with command name.
* `@DESCRIPTION@`: Replaced with the description.
