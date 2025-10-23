#!/usr/bin/env -S bash -e
#> @command-name: composer
#> @help-description: Runs composer commands inside the php container
#> @help-usage:$MAIN_SCRIPT_NAME composer [composer arguments]
#> # The ${ANSI_SUCCESS}$MAIN_SCRIPT_NAME composer${ANSI_END} script runs composer inside the php container.
#> #
#> # Examples:
#> #
#> #   $ $MAIN_SCRIPT_NAME composer install
#> #   $ $MAIN_SCRIPT_NAME composer update
#> #   $ $MAIN_SCRIPT_NAME composer require symfony/console
#> #   $ $MAIN_SCRIPT_NAME composer dump-autoload


# shellcheck disable=SC2124
ARGUMENTS="${@:1}"

dieIfDockerContainerNotRunning php

# shellcheck disable=SC2086
docker compose exec php composer $ARGUMENTS
