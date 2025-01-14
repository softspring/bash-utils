#!/bin/bash -e

# shellcheck disable=SC2034
COMMAND_NAME="stop"
COMMAND_HELP_DESCRIPTION="Stops the project"
COMMAND_HELP_USAGE="project stop"
COMMAND_HELP_TEXT="
  The ${ANSI_SUCCESS}project stop${ANSI_END} script stops the project.
"

[ -z "${UTILS_TMP_PATH}" ] && echo "Run $COMMAND_NAME command with project script:" && echo "$ $COMMAND_HELP_USAGE" && exit 1

function stop_docker_down {
    title "Stopping Docker environment..."
    dockerComposeDown
}

function run_stop {
    block 'STOP'
    gcloudSelectAccount "$GCLOUD_ACCOUNT"
    stop_docker_down
}
