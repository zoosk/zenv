# Environment Variables

## Built-in variables

The built-in variables that are used by ZEnv are:

| Name                      | Description                                                |
| ------------------------- | ---------------------------------------------------------- |
| ZENV_ROOT                 | The path to the ZEnv checkout.                             |
| ZENV_INITIALIZED          | Set to 1 if ZEnv is active.                                |
| ZENV_SETTINGS             | The path to the global settings file, `.zenvrc`.           |
| ZENV_WORKSPACE            | The folder where all checkouts are stored.                 |
| ZENV_WORKSPACE_SETTINGS   | The name of the checkout settings file, `work.properties`. |
| ZENV_CURRENT_WORK         | The path to the checkout currently being used.             |
| ZENV_BUILD_COMMAND        | The command used to build the current checkout.            |

Note that these are all prefixed with `ZENV`. For organizational purposes, it
is recommended that you prefix your own variables with that as well.
