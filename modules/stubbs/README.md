# stubs: Utility to create rerun modules

Use `stubbs` commands to define new *rerun* modules and commands

## Commands

### add-module

Make a new module named "freddy":

    rerun -m stubbs -c add-module  -- -name freddy -description "A dancer in a red beret and matching suspenders"

### add-command

Add a command named "dance" to the freddy module:

    rerun -m stubbs -c add-command -- -name dance -description "tell freddy to dance" -module freddy

### add-option

Define an option named "jumps":

    rerun -m stubbs -c add-option  -- -name jumps -description "jump #num times" -module freddy -command dance
