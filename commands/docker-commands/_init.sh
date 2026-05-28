#!/usr/bin/env -S bash -e

# shellcheck disable=SC2034
# current script timestamp
TIMESTAMP=$(date +%s)

# global project config file
if [[ -z "$GLOBAL_CONFIG_PATH" ]]; then
    GLOBAL_CONFIG_PATH="$HOME/.project"
fi
mkdir -p "$GLOBAL_CONFIG_PATH"
GLOBAL_CONFIG_FILE="$GLOBAL_CONFIG_PATH/config.env"

# create global file
createEmptyFile "$GLOBAL_CONFIG_FILE"

# user project config file if not exists
USER_PROJECT_CONFIG_FILE="$BASE_DIR/.env"
# create user project file if not exists
createEmptyFile "$USER_PROJECT_CONFIG_FILE"

function load_project_envs {
    loadEnvFile "$GLOBAL_CONFIG_FILE"
    loadEnvFile "$USER_PROJECT_CONFIG_FILE"
}

load_project_envs
