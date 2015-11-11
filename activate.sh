#! /usr/bin/env bash

#   Copyright 2015 Zoosk, Inc
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.

if [ "$ZENV_INITIALIZED" == 1 ]; then
    echoerr 'You are already using ZEnv.'
    exit 1
fi

if [ ! -e ~/.zenvrc ]; then
    echo 'You must install ZEnv before activating it. Run the install.sh script in your checkout.'
    exit 1
fi

# Build the subshell init out of your current bash login file and the ZEnv settings file, adding an auto-workspace init
INIT="$( ([[ -f ~/.bash_profile ]] && cat ~/.bash_profile) || ([[ -f ~/.bash_login ]] && cat ~/.bash_login) || ([[ -f ~/.profile ]] && cat ~/.profile) )
$(cat ~/.zenvrc)
trap deactivate EXIT
echo \"Welcome to ZEnv. \${RED}<3\${TXTRESET}\"
echo \"For help, type 'zhelp'.\"
if [ -n \"\$(grep -m 1 ZENV \"\$ZENV_WORKSPACE_SETTINGS\" 2>/dev/null)\" ]; then
    use \$(python -c \"from os import path; print path.relpath('\${PWD}', '\${ZENV_WORKSPACE}')\")
fi
"

# Start the subshell using the INIT variable
bash --rcfile <(echo "$INIT")
