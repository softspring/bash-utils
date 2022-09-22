# Bash utils

## Create project file

Create a project file in the project root.

```bash
#!/bin/bash -e
# #################################################################################
# SEE https://github.com/softspring/bash-utils
# #################################################################################
# shellcheck disable=SC2034
BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && realpath "$(pwd)" )"
SCRIPTS_DIR="$BASE_DIR/scripts"
VAR_DIR="$BASE_DIR/var"
UTILS_TMP_PATH=$VAR_DIR/bash-utils ; mkdir -p "$UTILS_TMP_PATH"
curl -H "Authorization: token xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" -s https://raw.githubusercontent.com/softspring/bash-utils/main/include.sh -o "$UTILS_TMP_PATH/include.sh"
curl -H "Authorization: token xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" -s https://raw.githubusercontent.com/softspring/bash-utils/main/include.sh -o "$UTILS_TMP_PATH/project.sh"
source "$UTILS_TMP_PATH/include.sh" all
source "$UTILS_TMP_PATH/project.sh"
```

Make it executable:

```bash
chmod +x project
```

## Create a new command

Create a *command*.sh file into scripts directory:

```bash
#!/bin/bash -e

# shellcheck disable=SC2034
COMMAND_NAME="example"
COMMAND_HELP_DESCRIPTION="Creates an example"
COMMAND_HELP_USAGE="project example"
COMMAND_HELP_TEXT="
  The ${ANSI_SUCCESS}project example${ANSI_END} script for this example.

  Additional usage explanations
"
#COMMAND_ARGUMENTS=0

[ -z "${UTILS_TMP_PATH}" ] && echo "Run $COMMAND_NAME command with project script:" && echo "$ $COMMAND_HELP_USAGE" && exit 1

function run {
  echo "DO RUN COMMAND!!!"
}
```