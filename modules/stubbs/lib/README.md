# Scripting language support

## Directory structure

Each language has a directory position under lib:

    $RERUN_MODULES/stubbs/lib/$INTERPRETER
    
For example, bash has:

    stubbs/lib/bash
    ├── generate-options
    ├── metadata
    └── templates
        ├── default.sh
        └── functions.sh
    
## Templates

* Command script
* Function library
    
## Metadata

Each language support library contains metadata with the following keys:

* `RERUN_SCRIPT_INTERPRETER`: Language name
* `RERUN_FUNCTION_LIB`: File name for the function library.
* `RERUN_COMMAND_SCRIPT`: File name for the command script.
* `RERUN_OPTIONS_SCRIPT`: File name for the options parser script.
* `RERUN_OPTIONS_GENERATOR`: Executable that generates an option parser script.

Example: stubbs/lib/bash/metadata

    RERUN_SCRIPT_INTERPRETER=bash
    RERUN_FUNCTION_LIB=functions.sh
    RERUN_COMMAND_SCRIPT=default.sh
    RERUN_OPTIONS_SCRIPT=options.sh
    RERUN_OPTIONS_GENERATOR=generate-options

    
