# ZEnv Quickstart

If you want to get a project running as quickly as possible without
understanding much about how to use all of ZEnv's features, this is the page
for you.


## Setting up the first time

You can skip to step 4 if somebody on your team has already checked in the
results of steps 1-3.

1. Modify `properties/global.properties` to add variables that you want to be
   available regardless of what checkout is being used. To force people to fill
   in values, write lines like this:

   `export FOO=@@echo 'default value'@@`

   The stuff between the `@@`s will be evaluated as the default, so you can do
   stuff like `$(whoami)`.

2. Copy the file `properties/default.work.properties` to
   `properties/XXX.work.properties`, where `XXX` is the name of the git repo
   you'll be working on. (For example, for ZEnv it would be `zenv`.) Modify
   that file in the same way as #1, but for properties specific to that kind of
   checkout. Make sure to change `ZENV_BUILD_COMMAND`.

3. Repeat #2 for each checkout you want to work with.

4. Run `python install.py` and answer the questions.

5. `git clone` your repository into the place that you told the install script
   that you have your checkouts.

6. `use XXX`, where `XXX` is the folder name of the repo you just cloned.

7. Repeat steps 5 & 6 for each repository you want to work with.


## Using ZEnv daily

`use <checkout_name>` to swap between checkouts.
