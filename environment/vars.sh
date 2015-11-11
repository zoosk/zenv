#! /usr/bin/env bash

#   Copyright 2015 Zoosk, Inc
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.

# Global environment settings for ZEnv. These settings differ from those in the .zenvrc file because they are
# not specific to a user.

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
