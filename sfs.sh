#!/usr/bin/env -S bash -e

BASH_UTILS_PATH="$( dirname -- "${BASH_SOURCE[0]}"; )";
MAIN_SCRIPT_NAME="$(basename "$0")" # maybe project

source "$BASH_UTILS_PATH/functions/commands.sh"
source "$BASH_UTILS_PATH/functions/docker.sh"
source "$BASH_UTILS_PATH/functions/env.sh"
source "$BASH_UTILS_PATH/functions/files.sh"
source "$BASH_UTILS_PATH/functions/gcloud.sh"
source "$BASH_UTILS_PATH/functions/prompt.sh"
source "$BASH_UTILS_PATH/functions/text.sh"
source "$BASH_UTILS_PATH/functions/utils.sh"
source "$BASH_UTILS_PATH/functions/yaml.sh"

message "Bash-utils ${ANSI_GREEN}$BASH_UTILS_VERSION${ANSI_END} in a $(osType) system\n"

# load base-commands
add_repository "$BASH_UTILS_PATH/commands/base-commands"