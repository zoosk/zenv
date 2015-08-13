#! /usr/bin/env bash

source "${ZENV_ROOT}/setupscripts/default.setup.sh"

if [ "$(which compass)" == '' ]; then
    TEMP='y'
    read -p "It doesn't look like you have compass installed. Would you like to install it now [y/n] (y)? " TEMP
    if [ "$TEMP" != 'n' ]; then
        echo 'Installing...'
        sudo gem install --version 0.11.7 compass
        sudo gem install --version 0.9 compass-susy-plugin
    fi
fi
