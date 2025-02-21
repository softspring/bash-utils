#!/bin/bash -e

function stop_docker_down {
    title "Stopping Docker environment..."
    dockerComposeDown
}
