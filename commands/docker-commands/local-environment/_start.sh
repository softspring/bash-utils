#!/bin/bash

function start_docker_build {
    title "Building Docker images..."
    dockerComposeBuild
}

function start_docker_up {
    title "Starting Docker environment..."
    dockerComposeUp "" "--force-recreate --remove-orphans"
}

function start_composer {
    title "\nRunning Composer..."
    dockerComposeExec php "composer install --no-scripts --no-ansi --no-progress --no-interaction"
}

function start_symfony {
    warning "Implement start_symfony function in your project to add any additional startup commands\n"
    # title "\nRunning Symfony startup commands..."
    # docker compose exec php bin/console doctrine:migrations:migrate -n --env=dev
    # docker compose exec php bin/console cache:clear --env=dev
    # docker compose exec php bin/console assets:install --env=dev
}