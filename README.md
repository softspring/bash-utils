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
curl -s https://api.github.com/repos/softspring/bash-utils/tags | grep 'tarball_url' | grep -Eo 'https://[^\"]*' | sed -n '1p' | xargs wget -q -O - | tar -xz --strip-components=1 -C $UTILS_TMP_PATH
BASH_UTILS_VERSION=$(curl -s https://api.github.com/repos/softspring/bash-utils/tags | grep 'name' | grep -Eo '[^\"]*' | tail -n2 | head -n1)
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