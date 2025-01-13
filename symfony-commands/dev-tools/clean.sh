#!/bin/bash -e

# shellcheck disable=SC2034
COMMAND_NAME="clean"
COMMAND_HELP_DESCRIPTION="Clears project caches"
COMMAND_HELP_USAGE="project clean"
COMMAND_HELP_TEXT="
  The ${ANSI_SUCCESS}project clean${ANSI_END} script cleans project caches (symfony, doctrine, cache pools, etc) to ensure a clean environment.
"

[ -z "${UTILS_TMP_PATH}" ] && echo "Run $COMMAND_NAME command with project script:" && echo "$ $COMMAND_HELP_USAGE" && exit 1

function run_clean {
    block 'CLEAN CACHES'

    dieIfDockerContainerNotRunning php

    title "Cleaning symfony caches"

    message "Cleaning var/cache dir: "
    dockerComposeExec php rm -rf var/cache/*
    success "Done\n"

    message "Running cache:clean command: "
    dockerComposeExec php bin/console cache:clean --env=dev
    success "Done\n"

    title "Cleaning doctrine caches"

    message "Running doctrine:cache:clean-metadata command: "
    dockerComposeExec php bin/console doctrine:cache:clean-metadata --env=dev
    success "Done\n"

    message "Running doctrine:cache:clean-collection-region command: "
    dockerComposeExec php bin/console doctrine:cache:clean-collection-region --all --env=dev
    success "Done\n"

    message "Running doctrine:cache:clean-entity-region command: "
    dockerComposeExec php bin/console doctrine:cache:clean-entity-region --all --env=dev
    success "Done\n"

    message "Running doctrine:cache:clean-query command: "
    dockerComposeExec php bin/console doctrine:cache:clean-query --env=dev
    success "Done\n"

    message "Running doctrine:cache:clean-query-region command: "
    dockerComposeExec php bin/console doctrine:cache:clean-query-region --env=dev
    success "Done\n"

    message "Running doctrine:cache:clean-result command: "
    dockerComposeExec php bin/console doctrine:cache:clean-result --env=dev
    success "Done\n"

    title "Cleaning cache pools"

    message "Running cache:pool:clear command: "
    dockerComposeExec php bin/console cache:pool:clear --all --env=dev
    success "Done\n"
}
