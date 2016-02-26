---
layout: docs
title: Checkouts
permalink: /docs/checkouts/
---

# Checkouts

ZEnv was created to manage changing environments between different checkouts.
This article describes how they are managed and represented.


## What are they?

A checkout is a folder within your workspace folder that contains a git
repository. Each one has two major features:

- The **name**, which is the name of the folder it resides in. This is used to
  select the checkout using the `use` command.
- The **type**, which is the name of the remote git repository, without forks.
  For example, the repo at https://github.com/github/scripts-to-rule-them-all
  has type 'scripts-to-rule-them-all'. The ZEnv repo type is just `zenv`.

ZEnv allows you to create different environments for each checkout type.


## How do they work?

### Properties

When you `use` a checkout for the first time, ZEnv will create a properties
file in that checkout's folder named `work.properties`. This file will be made
in exactly the same manner as the global `.zenvrc` file, except that instead
of using the `global.properties` file, it will use the `default.work.properties`
file by default.

For more information on template properties files, see installation.md.

When a developer switches their current checkout using the `use` command, the
`work.properties` file will execute in their environment, updating their set of
environment variables. This means that you can run arbitrary code when a user
enters a given checkout type, like helpfully printing the `git status`.


### Paths

The second thing that happens when a developer switches checkouts is that the
`$PATH` variable is modified. Each checkout has access to its own private set
of tools, contained in `bin/<checkout_type>/`, in addition to the ones that are
in `bin`. Don't worry if this folder doesn't exist yet -- it won't break.


## How do I use them?

To get the most out of ZEnv, you'll want to create several different template
properties files. To do this, simply create a file in the `properties` folder
that replaces "default" with the checkout type that you want it to work for.

For example, the maintainers of the above repo would create a file called
`scripts-to-rule-them-all.work.properties`. If you were working on ZEnv itself,
you would create a file called `zenv.work.properties`. These files would
override the default properties file.

Finally, it is **very important** that each of the files that you create
contains a `ZENV_BUILD_COMMAND` definition. This variable contains the text of
the command that the ubiquitous `build` command will run.


## Custom initialization

Like the install process, the checkout initialization process allows running
arbitrary code. Also like the install process, adding a file in the
`setupscripts` directory will change the code that runs.

By default, the code in `default.setup.sh` will run on every checkout
initialization. But, like properties files, you can override this for specific
checkouts by creating a file named after your checkout's type, such as
`zenv.setup.sh`.