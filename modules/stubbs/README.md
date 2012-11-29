The stubbs commands help you develop modules according to
the *rerun* layout conventions and metadata format. 
Stubbs won't write the implementations for you but
it will help keep you between the guard rails!

Use `stubbs:add-module` to define new rerun modules and 
`stubbs:add-command` to define commands.
Provide paramters to your commands by using `stubbs:add-option`
to give them named arguments. 
After defining your commands and options,
edit their scripts using `stubbs:edit` to open
the implementation in your configured text editor. 

Use `stubbs:docs` to generate documentation for
any module. This documentation is useful to both
the end users of your module as well as fellow contributors.
If stubbs docs aren't available to you online,
run `rerun stubbs:docs -m stubbs` to generate stubbs own documentation.

Stubbs includes support for unit testing modules through
the use of [roundup](http://bmizerany.github.com/roundup/).
Run a module's test plans via the `stubbs:test` command.
