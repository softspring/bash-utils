#!/bin/bash -e

# shellcheck disable=SC2034
COMMAND_NAME="start"
COMMAND_HELP_DESCRIPTION="Starts start the project"
COMMAND_HELP_USAGE="project start"
COMMAND_HELP_TEXT="
  The ${ANSI_SUCCESS}project start${ANSI_END} script starts the project for development.
"

[ -z "${UTILS_TMP_PATH}" ] && echo "Run $COMMAND_NAME command with project script:" && echo "$ $COMMAND_HELP_USAGE" && exit 1

function start_docker_build {
    title "Building Docker images..."
    dockerComposeBuild
}

function start_docker_up {
    title "Starting Docker environment..."
    dockerComposeUp "" "--force-recreate --remove-orphans"
}

function start_composer {
    title "\nRunning Composer..."
    dockerComposeExec php "composer install --no-scripts --no-ansi --no-progress --no-interaction"
}

function start_symfony {
    warning "Implement start_symfony function in your project to add any additional startup commands\n"
    # title "\nRunning Symfony startup commands..."
    # docker compose exec php bin/console doctrine:migrations:migrate -n --env=dev
    # docker compose exec php bin/console cache:clear --env=dev
    # docker compose exec php bin/console assets:install --env=dev
}

function run_start {
    block 'START'
    gcloudSelectAccount "$GCLOUD_ACCOUNT"

    start_docker_build
    start_docker_up
    start_composer
    start_symfony

    run_open
}
