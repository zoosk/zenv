#! /usr/bin/env bash

# Global environment settings for ZEnv. These settings differ from those in the .zenvrc file because they are
# mnot specific to a user.

# The name of the workspace settings files. Note that if you change this, it won't rename ones that are already there.
export ZENV_WORKSPACE_SETTINGS=work.properties

# The fancy colored prompt that appears.
export PS1='(\e[1;32mZ\e[1;34mEnv\e[00m) \W\$ '

# Color the output of grep when it's printing to stdout
export GREP_OPTIONS='--color=auto'
