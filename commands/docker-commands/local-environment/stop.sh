#!/bin/bash -e
#> @command-name: stop
#> @help-description: Stops the project
#> @help-usage: $MAIN_SCRIPT_NAME stop
#> # The ${ANSI_SUCCESS}$MAIN_SCRIPT_NAME stop${ANSI_END} script starts the project for development.

block 'STOP'
gcloudSelectAccount "$GCLOUD_ACCOUNT"
stop_docker_down
