#!/usr/bin/env -S bash -e

function add_repository {
    local DIR="$1"
    local COMMAND_PREFIX="$2"
    load_functions_directory "$DIR"
    load_commands_directory "$DIR" "$COMMAND_PREFIX"
}

# load (and run) util scripts stating with _ from repositories
function load_functions_directory {
    local LOAD_PATH="$1"

    for SCRIPT in "$LOAD_PATH"/*; do
        # SCRIPT_BASE_NAME=$(basename -- "$SCRIPT")
        SCRIPT_ID=$(basename -- "$SCRIPT" ".sh")

        # if is a directory, call recursively and continue
        [ -d "$SCRIPT" ] && load_functions_directory "$SCRIPT" "$SCRIPT_ID" && continue

        # skip tools scripts (starting with _)
        [ "${SCRIPT_ID:0:1}" != "_" ] && continue
        [ "$SCRIPT_ID" == "_" ] && continue

        debug "Loading ${SCRIPT/$BASE_DIR\//}\n"

        # shellcheck disable=SC1090
        source "$SCRIPT"
    done
}

# load commands from repositories
function load_commands_directory {
    local _COMMANDS_BASE_PATH="$1"
    local COMMAND_PREFIX="$2"

    for DIRECTORY in "$_COMMANDS_BASE_PATH"/*; do
        # if is not a directory, skip
        [ ! -d "$DIRECTORY" ] && continue

        _load_commands_in_dir "$DIRECTORY" "$COMMAND_PREFIX"
    done
}

_GROUPS_KEYS=()
_GROUPS_NAMES=()
_GROUPS_DESCRIPTIONS=()
_COMMANDS_GROUPS=()
_COMMANDS_KEYS=()
_COMMANDS_NAMES=()
_COMMANDS_NAMES_PREFIX=()
_COMMANDS_DESCRIPTIONS=()
_COMMANDS_USAGES=()
_COMMANDS_TEXTS=()
_COMMANDS_SCRIPT_PATHS=()

# load commands, storing ubication and help information extracted from "#> @attribute: " comments
function _load_commands_in_dir {
    local _COMMANDS_DIR="$1"
    local COMMAND_PREFIX="$2"

    local COMMAND_DIR_ID
    local SCRIPT_ID
    local COMMAND_KEY
    local COMMAND_NAME_PREFIX
    local SCRIPT

    COMMAND_DIR_ID=$(basename -- "$_COMMANDS_DIR")

    # Store group information >>
    local CURRENT_GROUP_INDEX
    for i in "${!_GROUPS_KEYS[@]}"; do
        if [[ "${_GROUPS_KEYS[$i]}" == "$COMMAND_DIR_ID" ]]; then
            CURRENT_GROUP_INDEX=$i
            break
        fi
    done
    if [ -z "$CURRENT_GROUP_INDEX" ]; then
        _GROUPS_KEYS+=("$COMMAND_DIR_ID")
        if [ -f "$_COMMANDS_DIR/_.sh" ]; then
            _GROUPS_NAMES+=("$(grep '^#> @group-name:' "$_COMMANDS_DIR/_.sh" | sed 's/#> @group-name:[[:space:]]*//' | tr -d '\n')")
            _GROUPS_DESCRIPTIONS+=("$(grep '^#> @group-description:' "$_COMMANDS_DIR/_.sh" | sed 's/#> @group-description:[[:space:]]*//' | tr -d '\n')")
        else
            _GROUPS_NAMES+=("")
            _GROUPS_DESCRIPTIONS+=("")
        fi
        CURRENT_GROUP_INDEX=$((${#_GROUPS_KEYS[@]} - 1))
    else
        if [ -f "$_COMMANDS_DIR/_.sh" ]; then
            _GROUPS_NAMES[$CURRENT_GROUP_INDEX]="$(grep '^#> @group-name:' "$_COMMANDS_DIR/_.sh" | sed 's/#> @group-name:[[:space:]]*//' | tr -d '\n')"
            _GROUPS_DESCRIPTIONS[$CURRENT_GROUP_INDEX]="$(grep '^#> @group-description:' "$_COMMANDS_DIR/_.sh" | sed 's/#> @group-description:[[:space:]]*//' | tr -d '\n')"
        fi
    fi
    # << Store group information

    # load commands
    for SCRIPT in "$_COMMANDS_DIR"/*; do
        # SCRIPT_BASE_NAME=$(basename -- "$SCRIPT")
        # SCRIPT=/home/user/example-commands/dev/hello.sh
        SCRIPT_ID=$(basename -- "$SCRIPT" ".sh") # hello
        COMMAND_KEY="${COMMAND_PREFIX:+$COMMAND_PREFIX-}${COMMAND_DIR_ID}-$(basename -- "$SCRIPT" ".sh")"

        # if is a directory, skip
        [ -d "$SCRIPT" ] && continue

        # skip tools scripts (starting with _)
        [ "${SCRIPT_ID:0:1}" == "_" ] && continue

        # skip not *.sh files
        [[ "$SCRIPT" != *.sh ]] && continue

        COMMAND_NAME=$(grep '^#> @command-name:' "$SCRIPT" | sed 's/#> @command-name:[[:space:]]*//' | tr -d '\n')
        COMMAND_DESCRIPTION=$(grep '^#> @help-description:' "$SCRIPT" | sed 's/#> @help-description:[[:space:]]*//' | tr -d '\n')
        COMMAND_USAGE=$(grep '^#> @help-usage:' "$SCRIPT" | sed 's/#> @help-usage:[[:space:]]*//' | tr -d '\n')
        COMMAND_TEXT=$(grep '^#> #' "$SCRIPT" | sed 's/^#> #[[:space:]]*//')
        COMMAND_NAME_PREFIX="${COMMAND_PREFIX:-${_GROUPS_NAMES[$CURRENT_GROUP_INDEX]}}"

        # Check if the command key already exists and overwrite if necessary
        for i in "${!_COMMANDS_KEYS[@]}"; do
            if [[ "${_COMMANDS_KEYS[$i]}" == "$COMMAND_KEY" ]]; then
                _COMMANDS_NAMES[$i]="$COMMAND_NAME"
                _COMMANDS_DESCRIPTIONS[$i]="$COMMAND_DESCRIPTION"
                _COMMANDS_USAGES[$i]="$COMMAND_USAGE"
                _COMMANDS_TEXTS[$i]="$COMMAND_TEXT"
                _COMMANDS_SCRIPT_PATHS[$i]="$SCRIPT"
                _COMMANDS_GROUPS[$i]="$COMMAND_DIR_ID"
                _COMMANDS_NAMES_PREFIX[$i]="$COMMAND_NAME_PREFIX"
                continue 2
            fi
        done

        # If the command key does not exist, add it to the arrays
        _COMMANDS_KEYS+=("$COMMAND_KEY")
        _COMMANDS_NAMES+=("$COMMAND_NAME")
        _COMMANDS_DESCRIPTIONS+=("$COMMAND_DESCRIPTION")
        _COMMANDS_USAGES+=("$COMMAND_USAGE")
        _COMMANDS_TEXTS+=("$COMMAND_TEXT")
        _COMMANDS_SCRIPT_PATHS+=("$SCRIPT")
        _COMMANDS_GROUPS+=("$COMMAND_DIR_ID")
        _COMMANDS_NAMES_PREFIX+=("$COMMAND_NAME_PREFIX")
    done
}

function _debug_commands {
    for i in "${!_COMMANDS_KEYS[@]}"; do
        echo "_COMMANDS_KEYS[$i]: ${_COMMANDS_KEYS[$i]}"
        echo "_COMMANDS_NAMES[$i]: ${_COMMANDS_NAMES[$i]}"
        echo "_COMMANDS_NAMES_PREFIX[$i]: ${_COMMANDS_NAMES_PREFIX[$i]}"
        echo "_COMMANDS_DESCRIPTIONS[$i]: ${_COMMANDS_DESCRIPTIONS[$i]}"
        echo "_COMMANDS_USAGES[$i]: ${_COMMANDS_USAGES[$i]}"
        echo "_COMMANDS_TEXTS[$i]: ${_COMMANDS_TEXTS[$i]}"
        echo "_COMMANDS_SCRIPT_PATHS[$i]: ${_COMMANDS_SCRIPT_PATHS[$i]}"
        echo
    done
}

function _debug_groups {
    for i in "${!_GROUPS_KEYS[@]}"; do
        echo "_GROUPS_KEYS[$i]: ${_GROUPS_KEYS[$i]}"
        echo "_GROUPS_NAMES[$i]: ${_GROUPS_NAMES[$i]}"
        echo "_GROUPS_DESCRIPTIONS[$i]: ${_GROUPS_DESCRIPTIONS[$i]}"
        echo
    done
}

function run_command {
    local COMMAND_INDEX
    for i in "${!_COMMANDS_KEYS[@]}"; do
        if [[ "${_COMMANDS_NAMES_PREFIX[$i]}" == "$1" && "${_COMMANDS_NAMES[$i]}" == "$2" ]]; then
            COMMAND_INDEX=$i
            shift 2
            break
        elif [[ -z "${_COMMANDS_NAMES_PREFIX[$i]}" && "${_COMMANDS_NAMES[$i]}" == "$1" ]]; then
            COMMAND_INDEX=$i
            shift
            break
        fi
    done

    # if command not found, show error message
    if [ -z "$COMMAND_INDEX" ]; then
        message "\nCommand not found\n\n" "error"

        message "Run "
        message "project help $COMMAND" "warning"
        message " to list available commands\n\n"
        exit 1
    fi

    # shellcheck disable=SC2034
    COMMAND_HELP_DESCRIPTION="${_COMMANDS_DESCRIPTIONS[$COMMAND_INDEX]}"
    # shellcheck disable=SC2034
    COMMAND_HELP_USAGE="${_COMMANDS_USAGES[$COMMAND_INDEX]}"
    # shellcheck disable=SC1090
    source "${_COMMANDS_SCRIPT_PATHS[$COMMAND_INDEX]}" "$@"
}
