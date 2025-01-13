#!/bin/bash -e

# shellcheck disable=SC2034
COMMAND_NAME="php"
COMMAND_HELP_DESCRIPTION="Runs php"
COMMAND_HELP_USAGE="project php"
COMMAND_HELP_TEXT="
  The ${ANSI_SUCCESS}project php${ANSI_END} command runs any php command inside the php container.

  Examples:

    $ project php -v
    $ project php -i
    $ project php composer install
    $ project php bin/console cache:clear
"

[ -z "${UTILS_TMP_PATH}" ] && echo "Run $COMMAND_NAME command with project script:" && echo "$ $COMMAND_HELP_USAGE" && exit 1

# you can change the container name if you want to run the command in a different container
PHP_CONTAINER_NAME="php"

function run_php {
  # shellcheck disable=SC2124
  local ARGUMENTS="${@:1}"

  dieIfDockerContainerNotRunning php

  # shellcheck disable=SC2086
  dockerComposeExec $PHP_CONTAINER_NAME php $ARGUMENTS
}
