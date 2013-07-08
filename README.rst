####
ZEnv
####

ZEnv is an environment that Zoosk developers can use to make their code deployment and debugging
processes easier. It provides a shell that allows the user to navigate between different checkouts
and deploy them to different servers.


Installation
============

To install ZEnv, run the install.sh script. It is preferred that you run the script from the
directory containing it, but not required. After answering the script's questions, you will be
prompted to create your first workspace (more on that later). Once you're through the questions,
just type

::

    ./activate.sh

And ZEnv will start!

Automatic startup
-----------------

If ZEnv is the only environment that you ever want to use (<3), you can add this line to your
.bash_login file to make it start automatically::

    source ~/.zenvrc

Just remember that this will *not* start a subshell, so if you hit Ctrl+D or run the ``deactivate``
command, you'll kill your whole command line.


Workspaces
==========

A workspace is a place that you work on code. Specifically, this is your checkout of Zoosk core.
When you begin coding using ZEnv, you will need to specify which checkout you're working in. This
tells ZEnv what code it should build.

To create a workspace, simply navigate to the checkout's directory and run ``work_init``. After
answering a few questions about where your code should be put when building, you can start using
your new workspace with the ``use`` command.

Example
-------

::

    svn co https://s.zoosk.com/zoosk/trunk zoosk  # Get the code
    cd zoosk
    work_init
    # A bunch of questions here
    use zoosk
    
You won't need to run ``work_init`` more than once; after the questions have been answered you
can simply ``use zoosk`` and everything will be ready.


Commands
========

Once you're all set up with some code and a workspace, you can start taking advantage of all
the utilities. Type ``zhelp`` to see a list of available built-in functions.


Modification
============

Modifying the settings of your ZEnv can be done by editing the ``.zenvrc`` file in your home
directory and the ``work.properties`` files in each of the workspaces. These files are in bash
syntax, so you can do whatever you want to change initialization for each workspace.

If you are thinking or writing code for ZEnv, **please** follow these patterns:

- Variables that are exported are prefixed with ``ZENV_``
- Functions are used for builtins, while scripts are for utilities
- Declared functions are always followed with ``export -f <function>``
- Functions should be documented in the ``zhelp`` script
- *Only* variable declarations go in the install.sh and work_init scripts
