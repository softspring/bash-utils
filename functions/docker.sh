#!/bin/bash -e

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

function dockerComposeRecreate {
    local CONTAINER="$1"

    if [[ -z "$CONTAINER" ]]; then
        title "\nStarting docker compose environment..."
        docker compose up -d
    else
        title "\nStarting docker compose $CONTAINER container..."
        docker compose up -d "$CONTAINER"
    fi
}

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

function dockerComposeDown {
    local CONTAINER="$1"

    if [[ -z "$CONTAINER" ]]; then
        title "\nStoping docker compose environment..."
        docker compose down --remove-orphans
        message "Docker environment is stopped\n"
    else
        title "\nStoping docker compose $CONTAINER container..."
        docker compose down "$CONTAINER"
        message "Docker $CONTAINER container is stopped\n"
    fi
}

function dockerComposeExec {
    local CONTAINER="$1"
    # shellcheck disable=SC2124
    local COMMAND=${@:2}

    docker compose exec "$CONTAINER" $COMMAND
}

function dockerContainerRunning {
    local CONTAINER="$1"

    set +e
    if [[ $(dockerGetContainerName $CONTAINER) == "" ]]; then
        # is not running
        echo 0
    else
        # is running
        echo 1
    fi
    set -e
}

function dieIfDockerContainerNotRunning {
    local CONTAINER="$1"

    if [[ $(dockerContainerRunning "$CONTAINER") == 0 ]]; then
        error "$CONTAINER container is not running with docker compose, maybe you need to start the project\n\n"
        exit 1
    fi
}

function dockerGetNetworkGateway {
    local CONTAINER="$1"
    local NETWORK="$2"

    docker inspect -f '{{ (index .NetworkSettings.Networks "'$NETWORK'").Gateway }}' "$CONTAINER"
}

function dockerGetNetworkIP {
    local CONTAINER="$1"
    local NETWORK="$2"

    docker inspect -f '{{ (index .NetworkSettings.Networks "'$NETWORK'").IPAddress }}' "$CONTAINER"
}

function dockerGetContainerName {
    local CONTAINER="$1"

    docker compose ps --format '{{.Name}}' $CONTAINER
}
