# The ZEnv Auto Builder

One of the most useful features that comes with ZEnv is the automatic builder. It watches
your computer for changes that you make to your workspace, then automatically uploads them
to your dev instance when you do. This makes for less time spent compiling and more time
spent debugging.

## How Can I Use it?

You need to have the Python library called MacFSEvents installed for the builder to run.
To install it, either type ``sudo pip install macfsevents`` or check out
https://pypi.python.org/pypi/MacFSEvents

After that, just run `autobuild`.


## How Does it Work?

The auto builder uses settings declared in `autobuild_settings` files in your checkout.
These files contain shell commands that will be run whenever you do something to a file.
Each settings file contains the rules for all files below it in the directory tree.


## A Simple Settings File
----------------------

Here is a very simple settings file:

    set TARGET_DIR=${ZENV_SERVERDIR}/public_html

    # Directly copy any .jpg files into the target directory
    \.jpg$
    	addupdate
    		cp $0 $TARGET_DIR/$0
    		chmod 755 $TARGET_DIR/$0
    	delete
    		rm $TARGET_DIR/$0

The structure of the file is very simple. First, there are one or more lines that begin
with the word "set." These will create variables that you can use in all of your rules.


   **NOTE: INDENTATION MATTERS. ALWAYS INDENT LIKE THIS. NEVER DO NOT.**

Following the variable setup we have the somewhat strange line `\.jpg$`. This is a regex
(oh no) that matches the filename of all .jpg files. This tells the builder that the
following rules are for any files that end with .jpg.

Finally, we have the meat of the code:

    addupdate
        cp $0 $TARGET_DIR/$0
        chmod 755 $TARGET_DIR/$0

This section specifies code that will be run when a file is either added or updated. There
are several choices for these "marker" lines:

  * all
  * add
  * update
  * delete
  * addupdate
  * adddelete
  * updatedelete

Following the marker line, we have an (almost) pure bash script that will be run. The only
difference is that the `$0` variable has as its value the path of the file that was
changed instead of its normal value of the name of the script being run.

When the above file is run, all .jpg files in your public_html directory will be kept in
sync with the ones in your source repository automatically as soon as you make changes.


## Advanced Tactics: Regex Groups

Astute readers may have picked up on that 1) regexes are used to match files, and that 2)
the numeric argument variables from Bash have been replaced. You (may have) guessed it!
Groups that you create in regexes are available as numeric variables in your scripts.
Here's a quick example:

    picture_of_([a-z]+)\.jpg
        all
            echo $1 is cool

In this example, whenever you change a file named ``picture_of_robin.jpg``, you will get a
log message from the auto builder that says "robin is cool".

Just what you wanted, right?
