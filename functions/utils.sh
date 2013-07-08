#! /usr/bin/env bash

##
# Utility functions.

##
# Tail the apache or syslog error logs on your dev instance.
# Usage (list logs): log
# Usage (syslog): log syslog
# Usage (apache): log log_name='error'
#
function log() {
    if [ "$1" == '' ]; then
        local CMD="ls -lt /var/log/apache2 | grep dev${ZENV_DEVID} | head"
    elif [ "$1" == 'syslog' ]; then
        local CMD="tail -f /var/log/syslog"
    else
        local LOGNAME='error'
        if [ "$2" != "" ]; then
            LOGNAME="$2"
        fi
        local CMD="tail -f /var/log/apache2/${1}_web4dev_dev${ZENV_DEVID}_${LOGNAME}.log_$(date '+%Y-%m-%d')"
    fi
    ssh "$ZENV_DEVSERVER" $CMD
}
export -f log

##
# Log into your dev instance
#
alias devbox="ssh \${ZENV_DEVSERVER}"

##
# Log into your database
#
alias dbbox="mysql -h \${ZENV_DBIP} -u root -pnwN9vrsbzl@vdc4f"

##
# Restart memcahced
# Usage (clear everything): clearmem
# Usage (clear one or more): clearmem cache_id...
#
function clearmem() {
    if [ "$1" == '' ]; then
        local ARGS="mem search cookie"
    else
        local ARGS=$*
    fi
    local CMD=$(for i in $ARGS; do echo $i | sed "s|\(.*\)|sudo /etc/init.d/memcached-\1-dev${ZENV_DEVID} restart;|"; done)
    ssh -t "$ZENV_DEVSERVER" "$CMD"
}
export -f clearmem
