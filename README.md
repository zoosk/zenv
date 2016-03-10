# ZEnv

ZEnv is a coding environment manager for programmers. It allows you to create a custom shell environment
that's stored in git, thereby keeping everyone in sync and allowing access to shared dev tools, aliases, and more.

## Features

### Developer setup

Developers must install your custom environment before working. When this happens,
you can run code that might install software dependencies, set up
git configuration, or create any directories needed for working. Never slog
through a complicated onboarding process again!

### Sharing dev tools

ZEnv allows the creation and sharing of any number of tools for making work
easier. Need to make sure everyone has access to a linter or test
runner? Just add it to the `bin` folder and check in.

### Shell customization

In addition to dev tools, you can add any amount of code that will run on your
developers' machines whenever they start a terminal. This allows you to share
build aliases, environment variables, and much more.

### Multiple projects

Sometimes you'll need to work with multiple checkouts of different projects,
each with their own set of requirements. ZEnv supports creating sub-environments,
allowing you to change the set of available dev tools and environment variables depending on what
developers need to work on at the time.


## Quick Start

1. Fork ZEnv so you can commit your updates.
2. Clone ZEnv onto your computer.
3. Optionally, write a script that will set up your environment in `setupscripts/global.setup.sh`
   (or create a fully [custom developer setup](wiki/Custom-Developer-Setup))
4. Optionally, add your personal dev tools to the `bin` folder.
5. Run `python install.py` to install the environment you've created.

After this, you're good to go! If you commit your changes, others will be able
to run `python install.py` as well to set up their computers.

Check out [the wiki](/wiki) for more information on how everything works.


## Examples


### Installing a technology stack

Any code that you add to `setupscripts/global.setup.sh` will run during initial
setup, when somebody runs `python install.py`. You can use this to install
your project's dependencies. For example, the following code makes sure that
everybody has `brew`, `node`, and `gulp`:

```
# Download homebrew for Mac
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
# Install node using brew
sudo brew install node
# Install gulp for building
npm install --global gulp-cli
```

When somebody new joins the project, this code will automatically run during their
ZEnv installation, setting up their computer completely painlessly.


### Sharing dev tools

Let's say you've decided to write a tool that parses production logs called `parse_logs`. It's very
useful for you, and you want others to use it as well. Sharing it with your
team is as simple as adding it to the `bin` folder and pushing:

```
cd "$ZENV_ROOT"  # This puts you in the ZEnv checkout
mv ~/bin/parse_logs bin/
git commit -am 'Adding parse_logs tool'
git push
```

After you've done this, your coworkers can use your new tool easily:

```
update_zenv  # Pick up changes from git
parse_logs
```


### Adding tab completion for git commands

Everybody loves tab completion, and Shawn O. Pearce has written an
[excellent bash script](https://github.com/git/git/blob/master/contrib/completion/git-completion.bash)
that will do it for git commands. You can add that script to your
company's computers by saving it in the `environment` folder with a `.sh`
extension. After restarting your terminal, all git commands will
automatically tab complete!

After trying it out, push your changes and have your coworkers run `update_zenv`
on their machines. They'll immediately benefit from your work.
