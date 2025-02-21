#!/bin/bash -e
#> @command-name: reset
#> @help-description: Resets local project
#> @help-usage: $MAIN_SCRIPT_NAME reset
#> # The ${ANSI_SUCCESS}$MAIN_SCRIPT_NAME reset${ANSI_END} script resets local project.

block 'RESET LOCAL ENVIRONMENT'
gcloudSelectAccount "$GCLOUD_ACCOUNT"

dockerComposeDown

start_docker_build

reset_database
reset_media

reset_docker_up
start_composer
start_symfony

reset_post_start

open_messages

success "\nDone! Project is reset.\n"
message "\nRun ${ANSI_WARNING}project open${ANSI_END} to open project in browser\n"