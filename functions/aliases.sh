##########################  UTILITY ALIASES  ##########################
# Log into your dev instance
alias devbox='if [ -z "$ZENV_CURRENT_WORK" ]; then echo "Set a workspace to SSH into its dev instance."; else ssh "${ZENV_DEVSERVER}"; fi'

# Log into your database
alias dbbox='if [ -z "$ZENV_CURRENT_WORK" ]; then echo "Set a workspace to SSH into its database."; else mysql -h ${ZENV_DBIP} -u root -pnwN9vrsbzl@vdc4f; fi'


##########################  BATCH BUILD ALIASES  ##########################
# Install everything
alias install-all='(install-most && install-test)'

# Reinstall everything
alias reinstall-all='(delete-all && install-all)'

# Install everything except test data
alias install-most='(build install-tools install-schwartz install-web install-web-test build-thrift-php-interface)'

# Get rid of all the work files (done using ssh for speed)
alias delete-all="(ssh -t \"\$ZENV_DEVSERVER\" \"rm -rf \${ZENV_SERVERDIR}/current/*\" 2>/dev/null)"

# Get rid of all the database info
alias delete-db='(build truncate-all)'


##########################  INDIVIDUAL PROJECT BUILD ALIASES  ##########################
# Install the API code
alias install-api='(buildweb install-web-api)'

# Install the include layer
alias install-inc='(buildweb install-web-include)'

# Install the web CSS
alias install-css='(buildstatic install-css)'

# Install the tools code
alias install-tools='(build upgrade-tools)'

# Install touch
alias install-touch='(buildweb install-web-touch)'

# Install web
alias install-web='(buildweb install-web-www)'

# Install the payment service
alias install-payments='(build install-and-build-payment-service)'

# Install test data
alias install-test='(buildweb install-test-500)'
