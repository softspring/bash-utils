# Bash utils

[![License](https://poser.pugx.org/softspring/bash-utils/license.svg)](https://packagist.org/packages/softspring/bash-utils)
[![Build status](https://github.com/softspring/bash-utils/actions/workflows/php.yml/badge.svg?branch=5.1)](https://github.com/softspring/bash-utils/actions/workflows/php.yml)

## Create project file

Create a project file in the project root.

```bash
#!/bin/bash -e
# #################################################################################
# SEE https://github.com/softspring/bash-utils
# #################################################################################
# shellcheck disable=SC2034
GITHUB_ACCESS_TOKEN="<your-github-token>"
BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && realpath "$(pwd)" )"
SCRIPTS_DIR="$BASE_DIR/scripts"
VAR_DIR="$BASE_DIR/var"
UTILS_TMP_PATH=$VAR_DIR/bash-utils ; mkdir -p "$UTILS_TMP_PATH"
# UTILS_TMP_PATH=./.git/bash-utils ; mkdir -p "$UTILS_TMP_PATH" # < to do it "hidden"
BASH_UTILS_VERSION=$(curl -H "Authorization: token $GITHUB_ACCESS_TOKEN" -s https://api.github.com/repos/softspring/bash-utils/releases | grep 'tag_name' | head -n1 | sed -n 's/.*"tag_name": "\(.*\)".*/\1/p' | tail -n2 | head -n1)
CURRENT_VERSION=$(cat "$UTILS_TMP_PATH/.version" 2> /dev/null || echo '')
[ "$CURRENT_VERSION" != "$BASH_UTILS_VERSION" ] && echo "# Updating bash-utils from $CURRENT_VERSION to $BASH_UTILS_VERSION ..." && curl -L "https://api.github.com/repos/softspring/bash-utils/tarball/refs/tags/$BASH_UTILS_VERSION" 2>/dev/null | tar -xz --strip-components=1 -C "$UTILS_TMP_PATH"
echo "$BASH_UTILS_VERSION" > "$UTILS_TMP_PATH/.version"
source "$UTILS_TMP_PATH/project.sh"
```

Make it executable:

```bash
chmod +x project
```

## Create a new command

Create a *example*.sh file into scripts directory:

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

[ -z "${UTILS_TMP_PATH}" ] && echo "Run $COMMAND_NAME command with project script:" && echo "$ $COMMAND_HELP_USAGE" && exit 1

function run_example {
  # GET ALL ARGUMENTS
  # shellcheck disable=SC2124
  local ARGUMENTS="${@:1}"
  
  # or SPLIT THEM
  local VARIABLE1="$1"
  local VARIABLE2="$2"
  
  echo "DO RUN COMMAND!!!"
}
```
