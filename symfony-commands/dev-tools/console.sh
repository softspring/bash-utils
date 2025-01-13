#!/bin/bash -e

# shellcheck disable=SC2034
COMMAND_NAME="console"
COMMAND_HELP_DESCRIPTION="Runs symfony console"
COMMAND_HELP_USAGE="project console"
COMMAND_HELP_TEXT="
  The ${ANSI_SUCCESS}project console${ANSI_END} script runs symfony console inside the php container.

  Examples:

    $ project console
    $ project console cache:clear
    $ project console doctrine:cache:clear-metadata
    $ project console debug:router

  There are several shortcuts available for this command. For more information, run:

    $ project help migrations
    $ project help fixtures
"

[ -z "${UTILS_TMP_PATH}" ] && echo "Run $COMMAND_NAME command with project script:" && echo "$ $COMMAND_HELP_USAGE" && exit 1

function run_console {
  # shellcheck disable=SC2124
  local ARGUMENTS="${@:1}"

  dieIfDockerContainerNotRunning php

  # shellcheck disable=SC2086
  dockerComposeExec php bin/console $ARGUMENTS
}
