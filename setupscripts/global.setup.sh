#! /usr/bin/env bash

# This script will run just before the ZEnv install process completes. If it
# exits with a 0 exit code, the installation is considered a success.

# Give the option to install MacFSEvents, as the autobuilder requires it
if [ "$(which clang)" != '' -a "$(python -c 'import fsevents' 2>/dev/null; echo $?)" == '1' ]; then
    read -p 'You need to have MacFSEvents installed if you want to use the automatic builder. Would you like to install it now [y/n] (y)? ' TEMP
    if [ "$TEMP" != 'n' ]; then
        if [ "$(which pip)" == '' ]; then
            sudo ARCHFLAGS=-Wno-error=unused-command-line-argument-hard-error-in-future easy_install macfsevents
        else
            sudo ARCHFLAGS=-Wno-error=unused-command-line-argument-hard-error-in-future pip install macfsevents
        fi
    fi
fi


# Make sure the local deploy dir exists
if [ ! -e "${ZENV_LOCAL_DEPLOY_DIR}" ]; then
    echo "Creating local deploy dir (${ZENV_LOCAL_DEPLOY_DIR}). You may be asked for your local sudo password."
    sudo mkdir -p ${ZENV_LOCAL_DEPLOY_DIR}
    USER="$(whoami)"
    sudo chown -R "$USER" "${ZENV_LOCAL_DEPLOY_DIR}"
fi

# Make sure everything that we need is writable by the current user
checkWritable() {
    touch "$1"/zenv_touched 2>/dev/null
    if [ $? -ne 0 ]; then
        echo "Your ${1} directory is not writable. If prompted, please enter your password below to fix this."
        USER="$(whoami)"
        sudo mkdir -p "$1"
        sudo chown -R "$USER" "$1"
    fi
    rm -f "$1"/zenv_touched 2>/dev/null
}
checkWritable "$ZENV_LOCAL_DEPLOY_DIR"
checkWritable "$ZENV_LOCAL_DEPLOY_DIR"/geodbdata
