#!/bin/bash -e

# shellcheck disable=SC2034
COMMAND_NAME="composer"
COMMAND_HELP_DESCRIPTION="Runs composer"
COMMAND_HELP_USAGE="project composer [composer arguments]"
COMMAND_HELP_TEXT="
  The ${ANSI_SUCCESS}project composer${ANSI_END} script runs composer inside the php container.

  Examples:

    $ project composer install
    $ project composer update
    $ project composer require symfony/console
    $ project composer dump-autoload
"

[ -z "${UTILS_TMP_PATH}" ] && echo "Run $COMMAND_NAME command with project script:" && echo "$ $COMMAND_HELP_USAGE" && exit 1

function run_composer {
  # shellcheck disable=SC2124
  local ARGUMENTS="${@:1}"

  dieIfDockerContainerNotRunning php

  # shellcheck disable=SC2086
  dockerComposeExec php composer $ARGUMENTS
}
