Use *stubbs:add-command* to add new commands to your module.

Create a new command
--------------------

After creating a module using [stubbs:add-module](../add-module/index.html),
add a command named "dance" to the freddy module:

    rerun stubbs:add-command --command dance --description "tell freddy to dance" --module freddy

The `add-command` module generates a boilerplate 
command script file you can edit.

	Wrote command script: /Users/alexh/.rerun/modules/freddy/commands/dance/script
	Wrote command test: /Users/alexh/.rerun/modules/freddy/tests/dance-1-test.sh

Of course, stubbs doesn't write the implementation for you, 
merely a stub.

Try running the freddy:dance command:

    $ rerun freddy:dance

The command should return without an error.

Use the [stubbs:edit](../edit/index.html) command to 
open the command script in your configured EDITOR to
give finish its implementation.

See the [stubbs:test](../test/index.html) command to
learn how to write a test plan for your new command.
