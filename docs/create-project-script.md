
## Create project file

Create a project file in the project root with the following content:

```bash
#!/usr/bin/env -S bash -e
# #################################################################################
# SEE https://github.com/softspring/bash-utils
# #################################################################################
# github .bash-utils read token
GITHUB_ACCESS_TOKEN="<your-github-token>"

# define paths
BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && realpath "$(pwd)" )"
SCRIPTS_DIR="$BASE_DIR/.scripts"
UTILS_TMP_PATH=$SCRIPTS_DIR/.bash-utils ; mkdir -p "$UTILS_TMP_PATH"
#UTILS_TMP_PATH=./.git/bash-utils ; mkdir -p "$UTILS_TMP_PATH" # < to do it "hidden"

# load last release of bash-utils
#RELEASE_FILTER=6.0
#BASH_UTILS_VERSION=$(curl -H "Authorization: token $GITHUB_ACCESS_TOKEN" -s https://api.github.com/repos/softspring/bash-utils/releases | grep '$RELEASE_FILTER' | grep 'tag_name' | head -n1 | sed -n 's/.*"tag_name": "\(.*\)".*/\1/p' | tail -n2 | head -n1)
#CURRENT_VERSION=$(cat "$UTILS_TMP_PATH/.version" 2> /dev/null || echo '')
#[ "$CURRENT_VERSION" != "$BASH_UTILS_VERSION" ] && echo "# Updating bash-utils from $CURRENT_VERSION to $BASH_UTILS_VERSION ..." && wget -q -O - "https://api.github.com/repos/softspring/bash-utils/tarball/refs/tags/$BASH_UTILS_VERSION" | tar -xz --strip-components=1 -C "$UTILS_TMP_PATH"
#echo "$BASH_UTILS_VERSION" > "$UTILS_TMP_PATH/.version"

# load last commit of branch
BRANCH="6.0"
BASH_UTILS_VERSION=$(curl -H "Authorization: token $GITHUB_ACCESS_TOKEN" -s https://api.github.com/repos/softspring/bash-utils/commits?sha=$BRANCH | grep 'sha' | head -n1 | sed -n 's/.*"sha": "\(.*\)".*/\1/p' | tail -n2 | head -n1)
CURRENT_VERSION=$(cat "$UTILS_TMP_PATH/.version" 2> /dev/null || echo '')
[ "$CURRENT_VERSION" != "$BRANCH-$BASH_UTILS_VERSION" ] && echo "# Updating bash-utils from $CURRENT_VERSION to $BRANCH-$BASH_UTILS_VERSION ..." && wget -q -O - "https://github.com/softspring/bash-utils/archive/$BASH_UTILS_VERSION.tar.gz" | tar -xz --strip-components=1 -C "$UTILS_TMP_PATH"
echo "$BRANCH-$BASH_UTILS_VERSION" > "$UTILS_TMP_PATH/.version"

# load code (new version sfs.sh, not project.sh to allow load commands from different locations)
source "$UTILS_TMP_PATH/sfs.sh"
# load_dir "$UTILS_TMP_PATH/docker-commands"
# load_dir "$UTILS_TMP_PATH/symfony-commands"
load_dir "$SCRIPTS_DIR"
#_debug_commands
find_command "$@"
run_command "$@"
exit 0
```

Make it executable:

```bash
chmod +x project
```

**Script explanation:**

- define `GITHUB_ACCESS_TOKEN` with your github token, to avoid rate limit
- define `BASE_DIR` and `SCRIPTS_DIR` paths
- maybe you will need to define `UTILS_TMP_PATH` to a hidden directory if you want to hide it
- load last release of bash-utils (uncomment the lines) os use the last commit of a branch (comment the release lines and uncomment the branch lines)
- load the code with `source "$UTILS_TMP_PATH/sfs.sh"`
- load the commands from the directories: docker-commands, symfony-commands and scripts
- find and run the command
