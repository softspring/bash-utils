#!/bin/bash -e

# shellcheck disable=SC2034
COMMAND_NAME="config"
COMMAND_HELP_DESCRIPTION="Setups project, creating needed resources and configurations"
COMMAND_HELP_USAGE="project config"
COMMAND_HELP_TEXT="
  The ${ANSI_SUCCESS}project config${ANSI_END} script helps to config project for developers.

  It makes all needed tasks to start project development, for example:

    - select gcloud account and project for development
    - configure local domain in ${ANSI_WARNING}/etc/hosts${ANSI_END}
    - creates development gcloud service account
    - creates development gcloud buckets
    - configure docker ${ANSI_WARNING}compose.yaml${ANSI_END} for user
"

[ -z "${UTILS_TMP_PATH}" ] && echo "Run $COMMAND_NAME command with project script:" && echo "$ $COMMAND_HELP_USAGE" && exit 1

function config_prompt_gcloud_project {
    title "Configure gcloud"
    promptGcloudAccount "$GCLOUD_ACCOUNT"
    saveEnvVariable "$USER_PROJECT_CONFIG_FILE" "GCLOUD_ACCOUNT" "$GCLOUD_ACCOUNT"
    promptGcloudProject "$GCLOUD_PROJECT"
    saveEnvVariable "$USER_PROJECT_CONFIG_FILE" "GCLOUD_PROJECT" "$GCLOUD_PROJECT"
}

function config_docker_compose {
    warning "Implement config_docker_compose function in your project to configure docker compose files\n"
}

function config_project {
    warning "Implement config_project function in your project to add any extra configuration steps\n"
}

function run_config {
    block "CONFIG"

    dockerComposeDown

    config_prompt_gcloud_project
    config_project
    config_docker_compose

    success "\nDone! Project is configured.\n"
    message "\nRun ${ANSI_WARNING}project start${ANSI_END} to start the project\n"
}
