#!/bin/bash -e

source "$UTILS_TMP_PATH/sfs.sh"

echo -e "\e[33mDEPRECATED: bash-utils/project.sh is deprecated, use bash-utils/sfs.sh instead, and load commands from multiple locations.\e[0m"

load_utils "$SCRIPTS_DIR"
load_commands "$SCRIPTS_DIR"
find_command "$@"
run_command "$@"
exit 0