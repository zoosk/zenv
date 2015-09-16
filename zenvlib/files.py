import fnmatch
import os


def glob_files(root_dir, pattern):
    """ Find all the files under a given directory that match a given pattern.
    :param root_dir: The directory to search in.
    :param pattern: The pattern.
    :return list: A list of filenames.
    """
    return [os.path.join(dirpath, f) for dirpath, dirnames, files in os.walk(root_dir) for f in fnmatch.filter(files, pattern) if '.gz' not in f]
