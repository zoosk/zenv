#! /usr/bin/env bash

if [ "$ZENV_INITIALIZED" == 1 ]; then
    echo 'You are already using ZEnv.'
    return 0
fi

bash --init-file ~/.zenvrc
