#!/bin/bash -e

# shellcheck disable=SC2034
COMMAND_NAME="migrations"
COMMAND_HELP_DESCRIPTION="Runs symfony migrations commands"
COMMAND_HELP_USAGE="project migrations"
COMMAND_HELP_TEXT="
  The ${ANSI_SUCCESS}project migrations${ANSI_END} script runs symfony migrations commands inside the php container.

  Examples:

    $ project migrations status
    $ project migrations migrate
    $ project migrations diff
    $ project migrations execute --up 20191231120000
    $ project migrations execute --down 20191231120000
    $ project migrations generate --namespace=App\\Migrations
"

[ -z "${UTILS_TMP_PATH}" ] && echo "Run $COMMAND_NAME command with project script:" && echo "$ $COMMAND_HELP_USAGE" && exit 1

function run_migrations {
  # shellcheck disable=SC2124
  local COMMAND="${@:1}"
  # shellcheck disable=SC2124
  local ARGUMENTS="${@:2}"

  dieIfDockerContainerNotRunning php

  # shellcheck disable=SC2086
  dockerComposeExec php bin/console doctrine:migrations:$COMMAND $ARGUMENTS
}
