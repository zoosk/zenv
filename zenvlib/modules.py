import subprocess


def install_if_needed(*module_names):
    """ Attempt to install a module using pip if it isn't installed. Note that if some modules need to be installed,
    this function will kill the current runtime. This is because the
    :param module_names: A mixed list of strings or tuples. Strings are module names that will be installed if they can't
        be imported; tuples are of the form (package_name, module_name) where the given package will be installed if the
        module can't be imported.
    """
    installed_modules = []

    for module_name in module_names:
        if type(module_name) == tuple:
            package_name = module_name[0]
            module_name = module_name[1]
        else:
            package_name = module_name
        try:
            __import__(module_name, globals(), locals())
        except ImportError, e:
            installed_modules.append(package_name)
            print 'You need to install the %s package to run this program. Installing...' % package_name

            # Install the dependency
            proc = subprocess.Popen('pip install --user %s' % package_name, shell=True)
            proc.wait()

            if proc.poll() != 0:
                # Something went wrong; check to make sure pip is installed and prompt the user if that's the case
                try:
                    subprocess.check_output(['which', 'pip'])
                except subprocess.CalledProcessError, e:
                    print 'Error installing dependency. Please make sure you have pip installed (you can install it via "sudo easy_install pip")'

                exit(1)

    if len(installed_modules) == 0:
        # No need to kill the program if we didn't install anything
        return
    elif len(installed_modules) == 1:
        print 'The %s package has been installed. Please start this program again.' % installed_modules[0]
    else:
        print 'All newly installed packages: %s' % ', '.join(installed_modules)
        print 'Please start this program again.'

    exit(0)
