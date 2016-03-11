#! /usr/bin/env bash

# This script will run on initialization of a new checkout, after the
# work.properties file has been created. If it exits successfully, the setup
# will be considered a success.

# For setup behavior specific to a given checkout type, create a script in this
# directory named <checkout_type>.setup.sh. For example, if my repo was named
# 'zoosk', I would create a file called 'zoosk.setup.sh'.

# If you need to write code that runs each time a checkout is used as opposed to
# when it is first set up, add your code to properties/default.work.properties
# instead.