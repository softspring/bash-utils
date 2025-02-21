#!/bin/bash -e
#> @command-name: logs
#> @help-description: Shows docker logs
#> @help-usage:$MAIN_SCRIPT_NAME logs
#> # The ${ANSI_SUCCESS}$MAIN_SCRIPT_NAME logs${ANSI_END} script shows docker logs.
#> #
#> # Examples:
#> #
#> #   $ $MAIN_SCRIPT_NAME logs
#> #   $ $MAIN_SCRIPT_NAME logs -f
#> #   $ $MAIN_SCRIPT_NAME logs --tail=100
#> #   $ $MAIN_SCRIPT_NAME logs nginx fpm fpm_xdebug
#> #   $ $MAIN_SCRIPT_NAME logs -f nginx

ARGUMENTS="${@:1}"

# shellcheck disable=SC2086
docker compose logs $ARGUMENTS
