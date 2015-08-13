# ZEnv

ZEnv is an environment manager for programming. It is based on the idea that a
busy developer must work on several different repositories, and that each
repository has its own build process, dev tools, and environment variables.

ZEnv automatically manages the user's `$PATH` and other environment variables
so that developers can maintain a clean, sensible environment regardless of
how many codebases they have to work with.

## Example 1: Building someone else's repo

Let's say you're an enterprising iOS developer working at a new company. You've
been hired to work on the app, but there's a completely separate team that
manages the database back-end. This means you have to worry about two repos:

- `db_backend`, which contains all of the DB team's code
- `app_frontend`, which contains all of your app code

In order to build a working test environment, you need to build both of these.
Without ZEnv, a typical build process might look like this:

    robink$ cd db_backend
    robink$ phing -logger phing.listener.DefaultLogger -Dprops=../mydevprops.properties
    ...
    robink$ cd ../app_frontend
    robink$ make
    ...

This works, but how long do you think it took to figure out the right syntax to
run the DB team's phing build? Why should you even need to know that command?
With ZEnv, the structure looks like this:

    robink$ use db_backend
    robink$ build
    ...
    robink$ use app_frontend
    robink$ build
    ...

Wow! So, what happened?

- `use` is a ZEnv command that changes the current checkout. It automatically
  `cd`'s you into the correct directory, and sets up your environment variables
  so that everything works.
- `build` is a ZEnv command that runs a build command appropriate to whatever
  checkout you're currently in. Each checkout has a properties file that's set
  up by its owners that specifies what command this should be.


## Example 2: Sharing command aliases

It's happened to everyone. You're over at a coworker's computer, and they type
some command you've never seen before. The screen lights up with the text of
five or six commands all running at once, commands that you've been manually
typing like a chump. Wouldn't it be great if you had that alias too?

Luckily for you, ZEnv can load whatever you want into your environment when you
start your terminal. So, you can go into ZEnv's `environment` folder and add
aliases.sh with this in it:

    alias starwars="telnet towel.blinkenlights.nl"

After you check in your changes, both you and your coworkers can benefit from
the glory of ASCII Star Wars. And hopefully your coworker will add their alias
too.


## Example 3: Creating dev tools

The `build` command is nice, but it's one of the only commands that ZEnv
provides. Instead of trying to think of everything, ZEnv gives you a new `bin`
folder and says "go." So let's say you've decided to write a linter for your
codebase. You've created an executable file called `lintit`, and you want
your team to start linting their code too.

All you need to do is add your file to the `bin` folder in ZEnv, and the linter
instantly becomes available to all parties.


## Quick Start

If you just want to get started without doing anything advanced, check out the
`quickstart.md` file in the docs folder.

That setup hardly scratches the surface of what's possible with ZEnv. For
more information on that, check out the docs in the `docs` folder.
