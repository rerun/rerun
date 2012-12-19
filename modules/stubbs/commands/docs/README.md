
Use *stubbs:docs* to generate a documentation site and a man page for your module.

The `stubbs:docs` command traverses your module files, reading
its structure, metadata, scripts, tests and user provided README
files to generate an HTML site helpful to users and contributors.

Requirements
------------
The `stubbs:docs` command depends on two software packages:

* [discount](http://www.pell.portland.or.us/~orc/Code/discount/)
* [pygmentize](http://pygments.org/docs/cmdline/)
  * On a Redhat/Centos system: 
  
           sudo yum install python-setuptools;
           sudo easy_install Pygments;
  
Generate the documentation
--------------------------

Run the "docs" command specifying a module.

    rerun stubbs:docs --module freddy

The `docs` command will print:

    Generated unix manual: /Users/alexh/rerun-workspace/rerun/modules/freddy/freddy.1

Display the man page
--------------------

Run `nroff` to display it:
	
	nroff -man /Users/alexh/rerun-workspace/rerun/modules/freddy/freddy.1 | more

Writing documentation
---------------------

The `stubbs:docs` command produces most of the content
from your module sources but you can provide extensive
usage documentation inside "README.md" files at
several levels of your module.

The diagram below points out where README.md files
can be placed.

    modules/freddy/
    |--README.md            <-- module usage
    |-- commands
    |   `-- dance
    |       |-- README.md   <-- command usage
    |       |-- metadata
    |       |-- options.sh
    |       `-- script
    |-- lib
    |   `-- functions.sh
    |-- metadata
    |-- options
    |   `-- jumps
    |       |-- README.md   <-- option usage
    |       `-- metadata
    `-- tests
        |-- functions.sh
        `-- dance-1-test.sh

