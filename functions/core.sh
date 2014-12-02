#! /usr/bin/env bash

##
# Core functions.

##
# Change the current workspace to be the one specified in $1
#
function use() {
    . zenv_use "$@"
}
export -f use

##
# Exit from ZEnv.
#
function deactivate() {
    echo "Goodbye. ZEnv will miss you while you're gone. :'("
    exit 0
}

PLATFORM=$(uname -a |grep -qi linux && echo 'linux' || echo 'osx');

##
# Uninstall ZEnv.
#
function uninstall_zenv() {
    read -p 'This will delete all your checkout configuration. Are you sure you want to continue [y/n]? ' TEMP
    if [ "$TEMP" == 'y' ]; then
        if [ $PLATFORM = 'osx' ]; then
            sed -i '' "/### BEGIN ZENV INIT/,/### END ZENV INIT/d" ~/.bash_login
            sed -i '' '/^alias zenv/d' ~/.bash_login
        else
            sed -i "/### BEGIN ZENV INIT/,/### END ZENV INIT/d" ~/.bash_login
            sed -i '/^alias zenv/d' ~/.bash_login
        fi
            
        rm -f "$ZENV_SETTINGS"
        echo "${RED}${BOLD}</3${TXTRESET} ZEnv has been uninstalled."
        exit 0
    fi
}
