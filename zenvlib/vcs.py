#   Copyright 2015 Zoosk, Inc
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.

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
            matches = re.findall('.*/([^/.]+)?(\.git)?\s*\(fetch\)', proc_output)
            if len(matches) > 0:
                self.checkout_type = matches[0][0]

            # Current branch
            proc_output = subprocess.check_output(['git', 'rev-parse', '--abbrev-ref', 'HEAD'], stderr=subprocess.PIPE)
            self.branch = proc_output.rstrip()

        except subprocess.CalledProcessError, e:
            # Git information is not accessible
            pass
