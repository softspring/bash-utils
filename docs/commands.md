## Commands

There are some command groups that you can use:

**Docker commands**

Includes a few commands to manage local environment with docker.

Import them uncommenting the line `load_dir "$UTILS_TMP_PATH/docker-commands"` in the project file.

```bash
load_dir "$UTILS_TMP_PATH/docker-commands"
```

This will load the following commands:

- project config: to configure project
- project start: to start the project
- project stop: to stop the project
- project open: to open the project

**Symfony and dev commands**

Includes a few commands to manage symfony projects.

Import them uncommenting the line `load_dir "$UTILS_TMP_PATH/symfony-commands"` in the project file.

```bash
load_dir "$UTILS_TMP_PATH/symfony-commands"
```

This will load the following commands:

- project clean: to clean the project caches
- project composer: to run composer commands
- project console: to run symfony console commands
- project logs: to show docker logs
- project migrations: to run migrations commands
- project php: to run commands in php container
- project yarn: to run commands in yarn container

## Create a new command

Create a *example*.sh file into scripts directory:

```bash
#!/usr/bin/env -S bash -e

# shellcheck disable=SC2034
COMMAND_NAME="example"
COMMAND_HELP_DESCRIPTION="Creates an example"
COMMAND_HELP_USAGE="project example"
COMMAND_HELP_TEXT="
  The ${ANSI_SUCCESS}project example${ANSI_END} script for this example.

  Additional usage explanations
"

[ -z "${UTILS_TMP_PATH}" ] && echo "Run $COMMAND_NAME command with project script:" && echo "$ $COMMAND_HELP_USAGE" && exit 1

function run_example {
  # GET ALL ARGUMENTS
  # shellcheck disable=SC2124
  local ARGUMENTS="${@:1}"
  
  # or SPLIT THEM
  local VARIABLE1="$1"
  local VARIABLE2="$2"
  
  echo "DO RUN COMMAND!!!"
}
```