#! /usr/bin/env bash


##########################  UTILITY ALIASES  ##########################
# Log into your dev instance
alias devbox='if [ -z "$ZENV_CURRENT_WORK" ]; then echo "Set a workspace to SSH into its dev instance."; else ssh "${ZENV_DEVSERVER}"; fi'

# Log into your database
alias dbbox='if [ -z "$ZENV_CURRENT_WORK" ]; then echo "Set a workspace to SSH into its database."; else mysql -h ${ZENV_DBIP} -u root -pnwN9vrsbzl@vdc4f; fi'


##########################  BUILD ALIASES  ##########################
# Install everything
alias install-all='(install-most && install-test)'

# Install everything except test data
alias install-most='(build install-tools install-schwartz install-web install-web-test build-thrift-php-interface)'

# Install test data
alias install-test='(buildweb install-test-500)'

# Reinstall everything
alias reinstall-all='(del-work && install-all)'

# Get rid of everything (done using ssh for speed)
alias del-work="(ssh -t \"\$ZENV_DEVSERVER\" \"rm -rf \${ZENV_SERVERDIR}/current/*\" 2>/dev/null)"
