Use *stubbs:add-module* to create a new rerun module.

Add a new module
----------------

Make a new module named "waitfor":

    rerun stubbs:add-module --module waitfor --description "utility commands that wait for a condition."

The `add-module` command will print:

    Created module structure: /Users/alexh/.rerun/modules/waitfor

* See the [stubbs:add-command](../add-command/index.html) command to create a 
command for your module.

Clone a module
--------------

Make a new module named "netutil" using "waitfor" as its template:

    rerun stubbs:add-module --module netutil --description "utility commands useful for checking net status." --template waitfor

The stubbs:add-module command will initilize an empty "netutil"
module and then populate it with the options and commands
declared in "waitfor".
