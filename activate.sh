#! /usr/bin/env bash

if [ "$ZENV_INITIALIZED" == 1 ]; then
    echo 'You are already using ZEnv.'
    exit 1
fi

if [ ! -e ~/.zenvrc ]; then
    echo 'You must install ZEnv before activating it. Run the install.sh script in your checkout.'
    exit 1
fi

# Auto init to a workspace if there's a properties file in the current directory
INIT='if [ "$(dirname $PWD)" == "$ZENV_WORKSPACE" -a -e "$ZENV_WORKSPACE_SETTINGS" ]; then use $(basename $PWD); fi'

# Start a subshell with the zenv settings file as the init file, and add the deactivate function to shell exits
bash --rcfile <(cat ~/.bash_login ~/.zenvrc; echo 'trap deactivate EXIT'; echo $INIT)
