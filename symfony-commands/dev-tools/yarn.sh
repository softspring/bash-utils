#!/bin/bash -e

# shellcheck disable=SC2034
COMMAND_NAME="yarn"
COMMAND_HELP_DESCRIPTION="Runs yarn command"
COMMAND_HELP_USAGE="project yarn"
COMMAND_HELP_TEXT="
  The ${ANSI_SUCCESS}project yarn${ANSI_END} command runs any yarn command inside the yarn container.

  Examples:

    $ project yarn -v
    $ project yarn add bootstrap
    $ project yarn add bootstrap@4.5.0
    $ project yarn remove bootstrap
    $ project yarn install
    $ project yarn upgrade
"

[ -z "${UTILS_TMP_PATH}" ] && echo "Run $COMMAND_NAME command with project script:" && echo "$ $COMMAND_HELP_USAGE" && exit 1

# you can change the container name if you want to run the command in a different container
YARN_CONTAINER_NAME="yarn"

function run_yarn {
  # shellcheck disable=SC2124
  local ARGUMENTS="${@:1}"

  dieIfDockerContainerNotRunning yarn

  # shellcheck disable=SC2086
  dockerComposeExec $YARN_CONTAINER_NAME yarn $ARGUMENTS
}
