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

import subprocess

def notify(message, title=None, subtitle=None):
    """ Deliver a desktop notification with the given message, title, and subtitle.
    :param message: The message to display.
    :param title: If specified, the title of the notification
    :param subtitle: If specified, the subtitle of the notification.
    """
    args = ['notify', '-message', message]
    if title is not None:
        args.extend(['-title', title])
    if subtitle is not None:
        args.extend(['-subtitle', subtitle])
    subprocess.call(args, stdout=subprocess.PIPE)
