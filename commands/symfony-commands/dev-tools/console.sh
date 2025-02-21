#!/bin/bash -e
#> @command-name: console
#> @help-description: Runs symfony console commands inside the php container
#> @help-usage:$MAIN_SCRIPT_NAME console [console command and arguments]
#> # The ${ANSI_SUCCESS}$MAIN_SCRIPT_NAME console${ANSI_END} script runs symfony console inside the php container.
#> #

# ensure docker container is running
dieIfDockerContainerNotRunning php

# NOTE: do not use dockerComposeExec, because it can break quoting of arguments
docker compose exec php bin/console "$@"
