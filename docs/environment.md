---
layout: docs
title: Environment
permalink: /docs/environment/
---

# Environment Setup

ZEnv provides the capacity to modify the environment based on the current
checkout, but it also allows you to create global environment variables and
initialization scripts using the `environment` directory.

Every `.sh` file in the `environment` directory will be loaded into the user's
environment at *startup time*. This means that these are all global settings.
These will only be re-loaded on shell start.


## Built-in environment setup

ZEnv provides several ease-of-use upgrades to the environment by default:

- Tab completion for git commands, written by Shawn O. Pearce.
- Several short-version git commands, such as `st` for `status` and `ci` for
  commit.
- Colorized grep output.
- Several variables useful for colorizing script output.

For a full list of these, read the `vars.sh` file in the `environment` folder.


## Implications

Any code that you could normally add to your `.bash_login` file is just as
useful in the `environment` directory as it is in your home directory. However,
anything that you check into your team's ZEnv repo will be replicated in every
other developer's environment. Be very careful to think about what you're
committing before you add something there.