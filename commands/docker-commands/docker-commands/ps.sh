#!/usr/bin/env -S bash -e
#> @command-name: ps
#> @help-description: Runs docker compose ps
#> @help-usage:$MAIN_SCRIPT_NAME ps
#> # The ${ANSI_SUCCESS}$MAIN_SCRIPT_NAME ps{ANSI_END} script runs docker compose ps.
#> #

# ensure docker container is running
dieIfDockerContainerNotRunning $SYMFONY_CONSOLE_CONTAINER_NAME

title "Running docker ps\n"

# NOTE: do not use dockerComposeExec, because it can break quoting of arguments
docker compose ps
