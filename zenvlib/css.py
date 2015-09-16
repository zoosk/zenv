import os
import re
import sys

from zenvlib import formatting
from zenvlib.files import glob_files
from zenvlib.modules import install_if_needed

install_if_needed('tinycss')
import tinycss


class_declaration_regex = re.compile("class=(\"([^\"]+)\"|'([^']+)')")
ng_class_regex = re.compile("[\"']([^\"']+)[\"']\s*:")


def load_css_from_dir(dirname, prefix='', verbose=False):
    """ Load CSS rule declarations from every file in a directory.
    :param dirname: The directory.
    :param prefix: Optionally, only read files with this name prefix.
    :param verbose: Optionally, print updates about what's going on.
    :return tinycss.css21.Stylesheet:
    """
    css_files = glob_files(dirname, prefix + '*')

    if verbose:
        total_size = 0
        for filename in css_files:
            total_size += os.path.getsize(filename)

        print 'Loading %s of CSS from %d files...' % (formatting.format_bytes(total_size), len(css_files)),
        sys.stdout.flush()

    combined_contents = []
    for filename in css_files:
        with open(filename, 'r') as fp:
            combined_contents.append(fp.read())

    combined_contents = "\n".join(combined_contents)

    parser = tinycss.make_parser('page3')
    stylesheet = parser.parse_stylesheet(combined_contents)

    if verbose:
        print 'Done. Loaded %d rule declarations.' % len(stylesheet.rules)

    return stylesheet


def load_css_from_file(filename):
    """ Shortcut for loading a CSS stylesheet from a file.
    :param filename: The file.
    :return tinycss.css21.Stylesheet:
    """
    parser = tinycss.make_parser('page3')
    return parser.parse_stylesheet_file(filename)


def classes_used_in_dir(dirname):
    """ Get all the classes that are used in a given directory of source files.
    :param dirname: The directory.
    :return set: A set of class names that were used.
    """
    files = glob_files(dirname, '*.soy')
    files.extend(glob_files(dirname, '*.html'))
    files.extend(glob_files(dirname, '*.php'))

    classes_used = set()
    for filename in files:
        classes_used.update(classes_used_in_file(filename))

    return classes_used


def classes_used_in_file(filename):
    """ Given a soy, js, or php file with class="" declarations, see which classes were used.
    :param filename: The file.
    :return set: The classes that were used.
    """
    with open(filename, 'r') as fp:
        class_exprs = [i[1] for i in re.findall(class_declaration_regex, fp.read())]

    used_classes = set()
    for decl in class_exprs:
        decl = decl.strip()
        if decl.startswith('{lb}'):
            # ng-class declaration; class names are in quotes
            used_classes.update(re.findall(ng_class_regex, decl))
        else:
            used_classes.update(decl.split(' '))

    return used_classes
