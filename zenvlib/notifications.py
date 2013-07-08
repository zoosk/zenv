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
