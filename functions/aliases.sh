#! /usr/bin/env bash

alias install-all='(install-most && buildweb install-test-500)'
alias install-most='(build install-tools install-schwartz install-web install-web-test build-thrift-php-interface)'
alias reinstall-all='(del-work && install-all)'
alias del-work="rm -rf \${ZENV_SERVERDIR}/current/*"
