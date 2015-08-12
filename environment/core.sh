#! /usr/bin/env bash

##
# Core functions. These are included here as functions because they need to modify
# the user's environment; do not place utilities here.
#

##
# Change the current checkout to be the one specified in $1
#
function use() {
    . "${ZENV_ROOT}/bin/use" "$@"
}
export -f use

##
# Exit from ZEnv.
#
function deactivate() {
    echo "Goodbye. ZEnv will miss you while you're gone. :'("
    exit 0
}

##
# Uninstall ZEnv.
#
function uninstall_zenv() {
    local STARTUP_FILE='~/.bash_profile'
    if [ ! -e "$STARTUP_FILE" ]; then
        STARTUP_FILE='~/.bash_login'
    fi
    if [ ! -e "$STARTUP_FILE" ]; then
        STARTUP_FILE='~/.profile'
    fi
    if [ ! -e "$STARTUP_FILE" ]; then
        echo 'Could not determine where your settings are stored.'
        return 1
    fi

    read -p 'This will delete all your checkout configuration. Are you sure you want to continue [y/n]? ' TEMP
    if [ "$TEMP" == 'y' ]; then
        if [ $PLATFORM = 'osx' ]; then
            sed -i '' '/### BEGIN ZENV INIT/,/### END ZENV INIT/d' "$STARTUP_FILE"
            sed -i '' '/^alias zenv/d' "$STARTUP_FILE"
        else
            sed -i '/### BEGIN ZENV INIT/,/### END ZENV INIT/d' "$STARTUP_FILE"
            sed -i '/^alias zenv/d' "$STARTUP_FILE"
        fi

        rm -f "$ZENV_SETTINGS"
        echo "${RED}${BOLD}</3${TXTRESET} ZEnv has been uninstalled."
        exit 0
    fi
}
