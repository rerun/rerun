Use *stubbs:rm-option* to remove an option.

Basic usage
-----------

Remove the  "--jumps" option from the `freddy:dance` command:

    rerun stubbs:rm-option --option jumps --module freddy --command dance

The command listing shows the --jumps option is no longer assigned.

    $ rerun freddy
    freddy:
     dance: tell freddy to dance

Like [stubbs:add-option](../add-option), the `rm-option` command
also updates the option parser script.

Pruning
-------

If you like to hack around your module sometimes using stubbs
(and sometimes not), you can end up with scripts or option metadata
that is inconsistent. 
You can run "rm-option" to clean things up.
