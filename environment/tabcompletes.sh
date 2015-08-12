#! /usr/bin/env bash

##
# This file contains the autocomplete setup functions for various programs.
#

## use/zenv_use
_tabcomp_use() {
    local cur workspaces
    workspaces=$(/bin/ls -F ${ZENV_WORKSPACE}/ | egrep "/$" | cut -d / -f 1)
    cur="${COMP_WORDS[COMP_CWORD]}"
    COMPREPLY=( $(compgen -W "${workspaces}" -- ${cur}) )
}
complete -F _tabcomp_use use
