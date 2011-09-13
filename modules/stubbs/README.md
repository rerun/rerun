# stubs: Utility to create stubbs modules

Use stubbs commands to define new rerun modules

## Commands

### add-module

Make a new module named "fitz":

    rerun -m stubbs -c add-module  -- -name fitz -description "fast dog"

### add-command

Add a command named "fetch" to the fitz module:

    rerun -m stubbs -c add-command -- -name fetch -description "get goin" -module fitz

### add-option

Define an option named "toy":

    rerun -m stubbs -c add-option  -- -name toy -description "the toy to fetch" -module fitz -command fetch
