Use *stubbs:archive* to create an archive of your modules.

Create a self extracting archive
--------------------------------

The default format is a self extracting shell script.

Create an archive containing the "freddy" module:

    rerun stubbs:archive --modules "freddy"

The `archive` command generates a "rerun.bin" file 
in the current directory.

Run the self extracting archive script without options and you
will see freddy's commands listed:

    $ bash rerun.bin
    freddy:
     dance: tell freddy to dance
        --jumps <>: "jump #num times"

Now run the `freddy:dance` command.

    $ bash rerun.bin freddy:dance --jumps 10
    jumps (10)

It works like a normal `rerun` command. Amazing !

Internal details
----------------

The archive format is a base64 encoded gzip'd tar file 
appended to a bash shell script
(e.g., cat EXTRACTSCRIPT PAYLOAD.tgz.base64 > RERUN.BIN).
The tar file contains payload content, specifically rerun and modules.

When the archive file is executed, 
the shell script reads the binary "attachment",
decompresses and unarchives the payload and then invokes
the rerun launcher.
The rerun launcher creates an ephemeral workspace to load
the included modules and then executes the included `rerun`
executable in the user's current working directory.

RPM format archives are built with "requires" and "provides" metadata that reflects Rerun's compliance with the [Semantic Versioning Specification](http://semver.org). The module RPM <i>requires</i> the (same) major version of both Rerun itself and the list of modules specified by the module's "REQUIRES" metdata token. Additionally, the  module RPM <i>provides</i> its major version to resolve installation depenendencies (typically using yum(8)).

Refer to the stubbs:archive script source for further details.
