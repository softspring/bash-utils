#!/bin/bash -e
#> @command-name: config
#> @help-description: Setups project, creating needed resources and configurations
#> @help-usage: $MAIN_SCRIPT_NAME config
#> # The ${ANSI_SUCCESS}$MAIN_SCRIPT_NAME config${ANSI_END} script helps to config project for developers.
#> #
#> # It makes all needed tasks to start project development, for example:
#> #
#> #    - select gcloud account and project for development
#> #    - configure local domain in ${ANSI_WARNING}/etc/hosts${ANSI_END}
#> #    - creates development gcloud service account
#> #    - creates development gcloud buckets
#> #    - configure docker ${ANSI_WARNING}compose.yaml${ANSI_END} for user

block "CONFIG"

dockerComposeDown

config_prompt_gcloud_project
config_gcloud_service_account
config_gcloud_buckets
config_local_domains
config_project

success "\nDone! Project is configured.\n"
message "\nRun ${ANSI_WARNING}project start${ANSI_END} to start (or restart) the project\n"