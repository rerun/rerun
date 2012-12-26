Use *stubbs:add-command* to add new commands to your module.

Create a new command
--------------------

After creating a module using [stubbs:add-module](../add-module/index.html),
add a command named "ping" to the waitfor module:

    rerun stubbs:add-command --module waitfor --command ping --description "wait for ping response from host"

The `add-command` module generates a boilerplate 
command script file you can edit.

	Wrote command script: /Users/alexh/.rerun/modules/waitfor/commands/ping/script
	Wrote command test: /Users/alexh/.rerun/modules/waitfor/tests/ping-1-test.sh

Of course, stubbs doesn't write the implementation for you, 
merely a stub.

Try running the waitfor:ping command:

    $ rerun waitfor:ping

The command should return without an error.

* Use the [stubbs:add-option](../add-option/index.html)
command to define options for the command.
* Use the [stubbs:edit](../edit/index.html) command to 
open the command script in your configured EDITOR to
give finish its implementation.
* See the [stubbs:test](../test/index.html) command to
learn how to write a test plan for your new command.
