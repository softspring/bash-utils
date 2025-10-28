#!/usr/bin/env -S bash -e

# Runs docker compose up command daemonize
# USAGE: dockerComposeUp [container] [parameters]
function dockerComposeUp {
    local CONTAINER="$1"
    local PARAMETERS="$2"

    if [[ -z "$CONTAINER" ]]; then
        title "\nStarting docker compose environment..."
        docker compose up -d $PARAMETERS
    else
        title "\nStarting docker compose $CONTAINER container..."
        docker compose up -d "$CONTAINER" $PARAMETERS
    fi
}

# Runs docker compose up command in daemon mode, recreating containers
# USAGE: dockerComposeRecreate [container]
# If no container is specified, recreates all services.
function dockerComposeRecreate {
    local CONTAINER="$1"

    if [[ -z "$CONTAINER" ]]; then
        title "\nStarting docker compose environment..."
        docker compose up -d --force-recreate
    else
        title "\nStarting docker compose $CONTAINER container..."
        docker compose up -d --force-recreate "$CONTAINER"
    fi
}

# Runs docker compose build command
# USAGE: dockerComposeBuild [container]
# If no container is specified, builds all services.
function dockerComposeBuild {
    local CONTAINER="$1"

    if [[ -z "$CONTAINER" ]]; then
        title "\nBuilding docker compose environment..."
        docker compose build
    else
        title "\nBuilding docker compose $CONTAINER container..."
        docker compose build "$CONTAINER"
    fi
}

# Runs docker compose down command
# USAGE: dockerComposeDown [container]
# If no container is specified, stops all services and removes orphans.
function dockerComposeDown {
    local CONTAINER="$1"

    if [[ -z "$CONTAINER" ]]; then
        title "\nStopping docker compose environment..."
        docker compose down --remove-orphans
        message "Docker environment is stopped\n"
    else
        title "\nStopping docker compose $CONTAINER container..."
        docker compose down "$CONTAINER"
        message "Docker $CONTAINER container is stopped\n"
    fi
}

# Runs docker compose exec command
# USAGE: dockerComposeExec [container] [command...]
# Executes a command in the specified container.
function dockerComposeExec {
    local CONTAINER="$1"
    # shellcheck disable=SC2124
    local COMMAND="${@:2}"

    docker compose exec "$CONTAINER" $COMMAND
}

# Checks if a docker container is running
# USAGE: dockerContainerRunning [container]
# Returns 1 if running, 0 if not.
function dockerContainerRunning {
    local CONTAINER="$1"

    set +e
    if [[ $(dockerGetContainerName "$CONTAINER") == "" ]]; then
        # is not running
        echo 0
    else
        # is running
        echo 1
    fi
    set -e
}

# Exits if a docker container is not running
# USAGE: dieIfDockerContainerNotRunning [container]
function dieIfDockerContainerNotRunning {
    local CONTAINER="$1"

    if [[ $(dockerContainerRunning "$CONTAINER") == 0 ]]; then
        error "$CONTAINER container is not running with docker compose, maybe you need to start the project\n\n"
        exit 1
    fi
}

# Gets the gateway IP of a docker container in a specific network
# USAGE: dockerGetNetworkGateway [container] [network]
function dockerGetNetworkGateway {
    local CONTAINER="$1"
    local NETWORK="$2"

    docker inspect -f '{{ (index .NetworkSettings.Networks "'$NETWORK'").Gateway }}' "$CONTAINER"
}

# Gets the IP address of a docker container in a specific network
# USAGE: dockerGetNetworkIP [container] [network]
function dockerGetNetworkIP {
    local CONTAINER="$1"
    local NETWORK="$2"

    docker inspect -f '{{ (index .NetworkSettings.Networks "'$NETWORK'").IPAddress }}' "$CONTAINER"
}

# Gets the docker compose container name
# USAGE: dockerGetContainerName [container]
function dockerGetContainerName {
    local CONTAINER="$1"

    docker compose ps --format '{{.Name}}' "$CONTAINER"
}

# Gets the subnet of a docker network
# USAGE: dockerGetNetworkSubnet [network]
function dockerGetNetworkSubnet {
    local NETWORK="$1"

    docker network inspect "$NETWORK" -f '{{ (index .IPAM.Config 0).Subnet }}'
}