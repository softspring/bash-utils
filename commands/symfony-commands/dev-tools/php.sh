#!/usr/bin/env -S bash -e
#> @command-name: php
#> @help-description: Runs php command inside the php container.
#> @help-usage:$MAIN_SCRIPT_NAME php [php command and arguments]
#> # The ${ANSI_SUCCESS}$MAIN_SCRIPT_NAME php${ANSI_END} script runs any php command inside the php container.
#> #
#> # Examples:
#> #
#> #   $ $MAIN_SCRIPT_NAME php -v
#> #   $ $MAIN_SCRIPT_NAME php -i
#> #   $ $MAIN_SCRIPT_NAME php composer install
#> #   $ $MAIN_SCRIPT_NAME php bin/console cache:clear

# shellcheck disable=SC2124
ARGUMENTS="${@:1}"

dieIfDockerContainerNotRunning php

# shellcheck disable=SC2086
docker compose exec $PHP_CONTAINER_NAME php $ARGUMENTS
