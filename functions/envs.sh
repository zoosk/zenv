#! /usr/bin/env bash

# Global environment settings for ZEnv. These settings differ from those in the .zenvrc file because they are
# mnot specific to a user.

# The name of the workspace settings files. Note that if you change this, it won't rename ones that are already there.
export ZENV_WORKSPACE_SETTINGS='work.properties'

# Colors!
export BOLD="$(tput bold)"
export DIM="$(tput dim)"
export UNDERLINE="$(tput smul)"
export BLACK="$(tput setaf 0)"
export RED="$(tput setaf 1)"
export GREEN="$(tput setaf 2)"
export YELLOW="$(tput setaf 3)"
export BLUE="$(tput setaf 4)"
export MAGENTA="$(tput setaf 5)"
export CYAN="$(tput setaf 6)"
export WHITE="$(tput setaf 7)"
export TXTRESET="$(tput sgr0)"

# The fancy colored prompt that appears.
export PS1="(${BOLD}${GREEN}Z${BLUE}Env${TXTRESET}) \\W\\\$ "

# Color the output of grep when it's printing to stdout
export GREP_OPTIONS='--color=auto'
