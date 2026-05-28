#!/usr/bin/env -S bash -e

# you can change the container name if you want to run the command in a different container
# can be overriden by setting PHP_CONTAINER_NAME in .env file but default value is php
PHP_CONTAINER_NAME=${PHP_CONTAINER_NAME:-php}

# you can change the container name if you want to run the command in a different container
# can be overriden by setting PHP_CONTAINER_NAME in .env file but default value is php
SYMFONY_CONSOLE_CONTAINER_NAME=${SYMFONY_CONSOLE_CONTAINER_NAME:-php}
