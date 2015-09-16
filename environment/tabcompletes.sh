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
complete -F _tabcomp_use zbranch

## worker
_tabcomp_worker() {
    local cur workers
    if [ "$ZENV_SERVERDIR" != '' ]; then
        workers=$(/bin/ls ${ZENV_SERVERDIR}/web/services/jobworkers | cut -d / -f 1)
        cur="${COMP_WORDS[COMP_CWORD]}"
        COMPREPLY=( $(compgen -W "${workers}" -- ${cur}) )
    else
        COMPREPLY=( $(compgen '' -- ${cur}) )
    fi
}
complete -F _tabcomp_worker worker

## webscript
_tabcomp_webscript() {
    local cur scripts dirbase
    if [ "$ZENV_SERVERDIR" != '' ]; then
        cur="${COMP_WORDS[COMP_CWORD]}"
        dirbase="${ZENV_SERVERDIR}/web/scripts"
        if [[ $cur == */* ]]; then
            local files=("${dirbase}/$2"*)
            [[ -e ${files[0]} ]] && COMPREPLY=( "${files[@]##${dirbase}/}" )
            for ((i=0; i < ${#COMPREPLY[@]}; i++)); do
                [ -d "${dirbase}/${COMPREPLY[$i]}" ] && COMPREPLY[$i]=${COMPREPLY[$i]}/
            done
        else
            scripts=$(/bin/ls -F ${dirbase})
            COMPREPLY=( $(compgen -W "${scripts}" -- ${cur}) )
        fi

    else
        COMPREPLY=( $(compgen '' -- ${cur}) )
    fi
}
complete -o nospace -F _tabcomp_webscript webscript

## webscript
_tabcomp_testscript() {
    local cur scripts dirbase
    if [ "$ZENV_SERVERDIR" != '' ]; then
        cur="${COMP_WORDS[COMP_CWORD]}"
        dirbase="${ZENV_SERVERDIR}/web/test"
        if [[ $cur == */* ]]; then
            local files=("${dirbase}/$2"*)
            [[ -e ${files[0]} ]] && COMPREPLY=( "${files[@]##${dirbase}/}" )
            for ((i=0; i < ${#COMPREPLY[@]}; i++)); do
                [ -d "${dirbase}/${COMPREPLY[$i]}" ] && COMPREPLY[$i]=${COMPREPLY[$i]}/
            done
        else
            scripts=$(/bin/ls -F ${dirbase})
            COMPREPLY=( $(compgen -W "${scripts}" -- ${cur}) )
        fi

    else
        COMPREPLY=( $(compgen '' -- ${cur}) )
    fi
}
complete -o nospace -F _tabcomp_testscript testscript


__tabcomp_unittest() {
    local cur scripts dirbase
    if [ "$ZENV_SERVERDIR" != '' ]; then
        cur="${COMP_WORDS[COMP_CWORD]}"
        testdir="${ZENV_SERVERDIR}/web/test"
        files=$(ls -LR ${testdir}/data ${testdir}/includes ${testdir}/suites ${testdir}/api)
        COMPREPLY=( $(compgen -W "$files" -- ${cur}) )
    else
        COMPREPLY=( $(compgen '' -- ${cur}) )
    fi     
}
complete -o nospace -F __tabcomp_unittest unittest

## zli
eval "$(_ZLI_COMPLETE=source /usr/local/bin/zli 2>/dev/null)"