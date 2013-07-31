#! /usr/bin/env bash

if [ "$ZENV_INITIALIZED" == 1 ]; then
    echo 'You are already using ZEnv.'
    return 0
fi

# Auto init to a workspace if there's a properties file in the current directory
INIT=""
if [ -e work.properties ]; then
    INIT+="use $(basename $PWD)"
fi

# Start a subshell with the zenv settings file as the init file, and add the deactivate function to shell exits
bash --rcfile <(cat ~/.bash_login ~/.zenvrc; echo 'trap deactivate EXIT'; echo $INIT)
