#!/usr/bin/env -S bash -e
#> @command-name: migrations
#> @help-description: Runs symfony migrations commands
#> @help-usage:$MAIN_SCRIPT_NAME migrations [migrations command and arguments]
#> # The ${ANSI_SUCCESS}$MAIN_SCRIPT_NAME migrations${ANSI_END} script runs symfony migrations commands inside the php container.
#> #
#> # Examples:
#> #
#> #   $ $MAIN_SCRIPT_NAME migrations status
#> #   $ $MAIN_SCRIPT_NAME migrations migrate
#> #   $ $MAIN_SCRIPT_NAME migrations diff
#> #   $ $MAIN_SCRIPT_NAME migrations execute --up 20191231120000
#> #   $ $MAIN_SCRIPT_NAME migrations execute --down 20191231120000
#> #   $ $MAIN_SCRIPT_NAME migrations generate --namespace=App\\Migrations

# shellcheck disable=SC2124
COMMAND="${@:1}"
# shellcheck disable=SC2124
ARGUMENTS="${@:2}"

dieIfDockerContainerNotRunning $SYMFONY_CONSOLE_CONTAINER_NAME

title "Running Symfony console doctrine:migrations:$COMMAND command into $SYMFONY_CONSOLE_CONTAINER_NAME container\n"

# shellcheck disable=SC2086
docker compose exec $SYMFONY_CONSOLE_CONTAINER_NAME bin/console doctrine:migrations:$COMMAND $ARGUMENTS
