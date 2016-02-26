---
layout: docs
title: Installation
permalink: /docs/installation/
---

# ZEnv Installation

This document will guide you through how to install ZEnv, and also how to
modify the installation process.

## What does it do?

When you install ZEnv, it will create a `.zenvrc` file in your home directory.
This file is a regular bash script that's imported into your environment on
startup. It contains all of the global variables that won't change between
checkouts. You might want to put things here like the developer's username.

After the install process is complete, users will need to restart their shells
to get into ZEnv.


## How do I use it?

The `.zenvrc` file is created using one of the properties file templates in the
`properties` directory, namely the `global.properties` file. During a simple
install, that file will be copied directly into `~/.zenvrc`. You can edit that
file to change the global properties included in developers' environments.

Once you've modified that file, you can install ZEnv by running
`python install.py`.


### Environment Variable Customization

The file isn't always copied directly. You can use the template placeholder
syntax to cause the installation process to ask the user to fill in some
properties for you. For example, this line

    export ZENV_USER_NAME=@@$(whoami)@@

means that the value of ZENV_USER_NAME must be filled in. The default value
for the question will be the result of `$(whoami)`. So, a user named robink
would see a line like this during his install process:

    Enter the value for the ZENV_USER_NAME global variable (robink): 
    
You can also customize the questions asked by adding comments, like so:

    # your user name
    export ZENV_USER_NAME=@@$(whoami)@@
    
This produces the prompt:

    Enter your user name (robink): 

If the user then answered that their name was "TheRobinator", their global
properties file would end up containing:

    export ZENV_USER_NAME=TheRobinator


### Install Process Customization

The install process can also have arbitrary code appended to it. To do this,
modify the `global.setup.sh` file in the `setupscripts` directory. This code
will run just after the regular install completes, and gives you an opportunity
to abort the process if everything isn't to your liking by exiting with a
nonzero exit code.