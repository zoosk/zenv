import re
import subprocess


class GitInfo(object):
    #: The checkout type, e.g. the name of the git repo
    checkout_type = None

    #: The current branch
    branch = None

    def __init__(self):
        try:
            # Checkout type
            proc_output = subprocess.check_output(['git', 'remote', '-v'], stderr=subprocess.PIPE)
            url = re.findall('(\S+)\s+\(fetch\)', proc_output)[0]
            matches = re.findall('.*?([^/.]+)/?(\.git)?$', url)
            if len(matches) > 0:
                self.checkout_type = matches[0][0]

            # Current branch
            proc_output = subprocess.check_output(['git', 'rev-parse', '--abbrev-ref', 'HEAD'], stderr=subprocess.PIPE)
            self.branch = proc_output.rstrip()

        except subprocess.CalledProcessError, e:
            # Git information is not accessible
            pass
