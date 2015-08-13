import re

from zenvlib import environ


class _PropsRegistry(object):
    """ Registry that holds loaded properties so they can be accessed quickly from code.
    """
    props_dict = {}

    loaded = False

    @classmethod
    def load(cls):
        """ Load the settings in from the property file(s).
        """
        if cls.loaded:
            return

        if not environ.initialized or environ.buildprops is None:
            raise Exception('No properties file available. Please run this while using a checkout in ZEnv.')

        separator = '='
        values = {}

        settings_string =''
        if environ.buildprops_common is not None:
            with open(environ.buildprops_common, 'r') as fp:
                settings_string += fp.read()

        settings_string += "\n"

        with open(environ.buildprops, 'r') as fp:
            settings_string += fp.read()

        settings = settings_string.split("\n")
        for line in settings:
            # Read the setting
            split = line.split(separator)
            name = split[0].strip()
            if len(split) == 1:
                # The value is empty
                values[name] = ''
            else:
                values[name] = split[1].strip()

        cls.props_dict = values
        cls.loaded = True

    @classmethod
    def unload(cls):
        """ Unload the cached property values. Useful when changing the active workspace.
        """
        cls.props_dict = {}
        cls.loaded = False

    @classmethod
    def get(cls, property_name):
        """ Get a property's value by name.
        :param property_name: The property's name
        :return str: The value with variables expanded as a string, or None if there is no such property
        """
        cls.load()

        # Expand all variables in the value
        if property_name not in cls.props_dict:
            return None

        old = cls.props_dict[property_name]
        while True:
            value = cls._expand_vars(old)
            if value == old:
                break
            old = value

        # Update the value so we don't have to go through the expansion loop next time
        cls.props_dict[property_name] = value
        return value

    @classmethod
    def _expand_vars(cls, string):
        """ Expand variable usages in a string with their values.
        :param string: Any string
        :return: The string with expanded values in it.
        """
        return re.sub('\$\{([^}]+)\}', '%(\\1)s', string) % cls.props_dict


def readprop(property_name):
    """ Get a property name from the currently used ZEnv properties files.
    :param property_name:
    :return:
    """
    return _PropsRegistry.get(property_name)
