#!/bin/bash -e
#> @command-name: start
#> @help-description: Starts the project
#> @help-usage: $MAIN_SCRIPT_NAME start
#> # The ${ANSI_SUCCESS}$MAIN_SCRIPT_NAME start${ANSI_END} script starts the project for development.

block 'START'
gcloudSelectAccount "$GCLOUD_ACCOUNT"

start_docker_build
start_docker_up
start_composer
start_symfony

run_open
