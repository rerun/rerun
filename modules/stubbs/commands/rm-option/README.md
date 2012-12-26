Use *stubbs:rm-option* to remove an option.

Basic usage
-----------

Remove the  "--interval" option from the `waitfor:ping` command:

    rerun stubbs:rm-option --option interval --module waitfor --command ping

The command listing shows the --interval option is no longer assigned.

    $ rerun waitfor
    ping: "wait for ping response from host"
       --host <>: "the host to reach"

Like [stubbs:add-option](../add-option), the `rm-option` command
also updates the option parser script.

Pruning
-------

If you like to hack around your module sometimes using stubbs
(and sometimes not), you can end up with scripts or option metadata
that is inconsistent. 
You can run "rm-option" to clean things up.
