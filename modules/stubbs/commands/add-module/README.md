Use *stubbs:add-module* to create a new rerun module.

Add a new module
----------------

Make a new module named "freddy":

    rerun stubbs:add-module --module freddy --description "A dancer in a red beret and matching suspenders" 

The `add-module` command will print:

    Created module structure: /Users/alexh/.rerun/modules/freddy

See the [stubbs:add-command](../add-command) command to create a 
command for your module.

Clone a module
--------------

Make a new module named "roger" using "freddy" as its template:

    rerun stubbs:add-module --module roger --description "Another friend of rerun." --template roger

The stubbs:add-module command will initilize an empty "roger"
module and then populate it with the options and commands
like those contained in "freddy".
