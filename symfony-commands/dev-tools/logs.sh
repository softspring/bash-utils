#!/bin/bash -e

# shellcheck disable=SC2034
COMMAND_NAME="logs"
COMMAND_HELP_DESCRIPTION="Shows docker logs"
COMMAND_HELP_USAGE="project logs"
COMMAND_HELP_TEXT="
  The ${ANSI_SUCCESS}project logs${ANSI_END} script shows docker logs.

  Examples:

    $ project logs
    $ project logs -f
    $ project logs --tail=100
    $ project logs nginx fpm fpm_xdebug
    $ project logs -f nginx
"

[ -z "${UTILS_TMP_PATH}" ] && echo "Run $COMMAND_NAME command with project script:" && echo "$ $COMMAND_HELP_USAGE" && exit 1

function run_logs {
  # shellcheck disable=SC2124
  local ARGUMENTS="${@:1}"

  # shellcheck disable=SC2086
  docker compose logs $ARGUMENTS
}
