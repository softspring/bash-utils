#!/bin/bash -e

# shellcheck disable=SC2034
COMMAND_NAME="open"
COMMAND_HELP_DESCRIPTION="Opens local project"
COMMAND_HELP_USAGE="project open"
COMMAND_HELP_TEXT="
  The ${ANSI_SUCCESS}project open${ANSI_END} script opens project in browser.
"

[ -z "${UTILS_TMP_PATH}" ] && echo "Run $COMMAND_NAME command with project script:" && echo "$ $COMMAND_HELP_USAGE" && exit 1

function run_open {
    block 'OPEN'

    message "\nCheck application at https://$LOCAL_DEFAULT_DOMAIN/\n\n"
    openBrowser "https://$LOCAL_DEFAULT_DOMAIN/"
}
