#!/bin/bash -e
#> @command-name: yarn
#> @help-description: Runs yarn command
#> @help-usage:$MAIN_SCRIPT_NAME yarn [yarn arguments]
#> # The ${ANSI_SUCCESS}$MAIN_SCRIPT_NAME yarn${ANSI_END} script runs yarn inside the yarn container.
#> #
#> # Examples:
#> #
#> #   $ $MAIN_SCRIPT_NAME yarn -v
#> #   $ $MAIN_SCRIPT_NAME yarn add bootstrap
#> #   $ $MAIN_SCRIPT_NAME yarn add bootstrap@4.5.0
#> #   $ $MAIN_SCRIPT_NAME yarn remove bootstrap
#> #   $ $MAIN_SCRIPT_NAME yarn install
#> #   $ $MAIN_SCRIPT_NAME yarn upgrade


# you can change the container name if you want to run the command in a different container
YARN_CONTAINER_NAME=${YARN_CONTAINER_NAME:-yarn}

# shellcheck disable=SC2124
ARGUMENTS="${@:1}"

dieIfDockerContainerNotRunning yarn

# shellcheck disable=SC2086
docker compose exec $YARN_CONTAINER_NAME yarn $ARGUMENTS
