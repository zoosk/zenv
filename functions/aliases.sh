#! /usr/bin/env bash


##########################  UTILITY ALIASES  ##########################
# Log into your dev instance
alias devbox="ssh \${ZENV_DEVSERVER}"

# Log into your database
alias dbbox="mysql -h \${ZENV_DBIP} -u root -pnwN9vrsbzl@vdc4f"


##########################  BUILD ALIASES  ##########################
# Install everything
alias install-all='(install-most && install-test)'

# Install everything except test data
alias install-most='(build install-tools install-schwartz install-web install-web-test build-thrift-php-interface)'

# Install test data
alias install-test='(build-web install-test-500)'

# Reinstall everything
alias reinstall-all='(del-work && install-all)'

# Get rid of everything
alias del-work="rm -rf \${ZENV_SERVERDIR}/current/*"
