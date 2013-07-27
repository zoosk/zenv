#! /usr/bin/env bash

# Global environment settings for ZEnv. These settings differ from those in the .zenvrc file because they are
# mnot specific to a user.

# The fancy colored prompt that appears.
export PS1='(\e[1;32mZ\e[1;34mEnv\e[00m) \W\$ '

# Color the output of grep when it's printing to stdout
export GREP_OPTIONS='--color=auto'
