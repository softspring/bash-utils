# Bash utils

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
BASH_UTILS_VERSION=$(curl -H "Authorization: token $GITHUB_ACCESS_TOKEN" -s https://api.github.com/repos/softspring/bash-utils/releases | grep 'tag_name' | head -n1 | grep -Eo '[^\"]*' | tail -n2 | head -n1)
CURRENT_VERSION=$(cat "$UTILS_TMP_PATH/.version" 2> /dev/null || echo '')
[ "$CURRENT_VERSION" != "$BASH_UTILS_VERSION" ] || wget -q -O - "https://api.github.com/repos/softspring/bash-utils/tarball/refs/tags/$BASH_UTILS_VERSION" | tar -xz --strip-components=1 -C "$UTILS_TMP_PATH"
echo "$BASH_UTILS_VERSION" > "$UTILS_TMP_PATH/.version"
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