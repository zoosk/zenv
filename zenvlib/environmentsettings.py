import os


class EnvironmentSettings(object):
    #: The path to the build properties file
    buildprops = None

    #: The path to the common properties file
    buildprops_common = None

    #: The build command used to start a build in this checkout.
    build_command = None

    #: The command that runs on completion of a build.
    complete_command = None

    #: The path to the current workspace.
    current_work = None

    #: The IP address of the database box.
    dbip = None

    #: The dev ID for this checkout.
    devid = None

    #: The 3-digit, 0-padded devid
    devid_padded = None

    #: The hostname of the dev server for this checkout.
    devserver = None

    #: The command that runs on build failure.
    failed_command = None

    #: Whether or not the user is in ZEnv.
    initialized = False

    #: The user's LDAP username.
    ldap_username = None

    #: The path to the root of the local deploy dir.
    local_deploy_dir = None

    #: The root of the ZEnv checkout.
    root = None

    #: The directories to rsync after a build completes.
    rsync_directories = None

    #: The path to the deployed version of this checkout.
    serverdir = None

    #: The path to the global settings file.
    settings = None

    #: The path to the workspace folder that contains the checkouts.
    workspace = None

    #: The name of the workspace-specific settings file
    workspace_settings = None

    def __init__(self):
        env_vars = os.environ

        # Load all the vars
        for key, value in env_vars.iteritems():
            if key.startswith('ZENV_'):
                attr_name = key[5:].lower()
                setattr(self, attr_name, value)

        # Add data types to non-string properties
        self.initialized = (self.initialized == '1')

        if self.rsync_directories is not None:
            self.rsync_directories = self.rsync_directories.split(' ')
        else:
            self.rsync_directories = []

        if self.buildprops_common == '':
            self.buildprops_common = None

        self._env_loaded = True

    def __setattr__(self, key, value):
        """ Override __setattr__ to make all properties read-only """
        if hasattr(self, '_env_loaded'):
            raise Exception('Properties of EnvironmentSettings objects are read-only')
        else:
            self.__dict__[key] = value

