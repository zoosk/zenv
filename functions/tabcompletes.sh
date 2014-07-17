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
complete -F _tabcomp_use zenv_use
complete -F _tabcomp_use use
complete -F _tabcomp_use zbranch

## worker
_tabcomp_worker() {
    local cur workers
    if [ "$ZENV_SERVERDIR" != '' ]; then
        workers=$(/bin/ls ${ZENV_SERVERDIR}/current/web/services/jobworkers | cut -d / -f 1)
        cur="${COMP_WORDS[COMP_CWORD]}"
        COMPREPLY=( $(compgen -W "${workers}" -- ${cur}) )
    else
        COMPREPLY=( $(compgen '' -- ${cur}) )
    fi
}
complete -F _tabcomp_worker worker