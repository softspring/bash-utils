#!/usr/bin/env -S bash -e

function stop_docker_down {
    title "Stopping Docker environment..."
    dockerComposeDown
}
