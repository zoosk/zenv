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
export PS1="(\[${BOLD}${GREEN}\]Z\[${BLUE}\]Env\[${TXTRESET}\]) ${PS1}"

# Color the output of grep when it's printing to stdout
export GREP_OPTIONS='--color=auto'

# Make the ZEnv Python library, zenvlib, importable
export PYTHONPATH="${ZENV_ROOT}:${PYTHONPATH}"

# If you like colored dir listings enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
fi

# Attempt to use the extra git config
GIT_CONFIG="${ZENV_ROOT}/utils/gitconfig.cfg"
if [ "$(which git)" != '' -a "$(git config --get include.path 2>/dev/null | grep "$GIT_CONFIG")" == '' ]; then
    git config --global include.path "$GIT_CONFIG"
fi

# Fix XAMPP's overwriting of the head function so that scripts don't crash
alias head=/usr/bin/head
