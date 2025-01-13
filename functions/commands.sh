#!/bin/bash

# load_utils ".dev" # load util scripts stating with _ from .dev directory (not _index)
function load_utils {
    local LOAD_PATH="$1"

    for SCRIPT in "$LOAD_PATH"/*; do
        # SCRIPT_BASE_NAME=$(basename -- "$SCRIPT")
        SCRIPT_ID=$(basename -- "$SCRIPT" ".sh")

        # if is a directory, call recursively and continue
        [ -d "$SCRIPT" ] && load_utils "$SCRIPT" "$SCRIPT_ID" && continue

        # skip tools scripts (starting with _)
        [ "${SCRIPT_ID:0:1}" != "_" ] && continue
        [ "$SCRIPT_ID" == "_index" ] && continue

        # message "Loading \"$SCRIPT_ID\" script\n"
        # shellcheck disable=SC1090
        source "$SCRIPT"
    done
}

declare -A _COMMANDS_GROUP_NAME
declare -A _COMMANDS_GROUP
declare -A _COMMANDS_NAMES
declare -A _COMMANDS_FILES
declare -A _COMMANDS_OVERWRITTEN
declare -A _COMMANDS_HELP_DESCRIPTION
declare -A _COMMANDS_HELP_USAGE
declare -A _COMMANDS_HELP_TEXT
declare -A _GROUPS_NAMES
declare -A _GROUPS_TITLES

# this is internal function, do not use it
function _load_commands_in_dir {
    local COMMANDS_DIR="$1"

    # define variables
    local COMMAND_DIR_ID
    local SCRIPT_ID
    local COMMAND_KEY
    local SCRIPT

    COMMAND_DIR_ID=$(basename -- "$COMMANDS_DIR")

    for SCRIPT in "$COMMANDS_DIR"/*; do
        # SCRIPT_BASE_NAME=$(basename -- "$SCRIPT")
        # SCRIPT=/home/user/example-commands/dev/hello.sh
        SCRIPT_ID=$(basename -- "$SCRIPT" ".sh") # hello
        COMMAND_KEY="${COMMAND_DIR_ID}-$(basename -- "$SCRIPT" ".sh")"

        # if is a directory, skip
        [ -d "$SCRIPT" ] && continue

        # skip tools scripts (starting with _)
        [ "${SCRIPT_ID:0:1}" == "_" ] && continue

        # shellcheck disable=SC2034
        # do not keep other commands variables
        COMMAND_GROUP=
        # load _index file if exists
        [[ -f "$COMMANDS_DIR/_index.sh" ]] && source "$COMMANDS_DIR/_index.sh"

        _GROUPS_NAMES["$COMMAND_DIR_ID"]="$COMMAND_GROUP"
        _GROUPS_TITLES["$COMMAND_DIR_ID"]="$COMMAND_HELP_TITLE"

        # shellcheck disable=SC2034
        # do not keep other commands variables
        COMMAND_NAME=
        COMMAND_HELP_DESCRIPTION=
        COMMAND_HELP_USAGE=
        COMMAND_HELP_TEXT=
        # shellcheck disable=SC1090
        source "$SCRIPT"

        # check if already defined
        _COMMANDS_OVERWRITTEN["$COMMAND_KEY"]="0"
        if [[ "${_COMMANDS_NAMES[$COMMAND_KEY]}" ]]; then
            _COMMANDS_OVERWRITTEN["$COMMAND_KEY"]="1"
        fi

        _COMMANDS_GROUP["$COMMAND_KEY"]="$COMMAND_DIR_ID"
        _COMMANDS_NAMES["$COMMAND_KEY"]="$COMMAND_NAME"
        _COMMANDS_FILES["$COMMAND_KEY"]="$SCRIPT"
        if [[ -n $COMMAND_GROUP ]]; then
            _COMMANDS_GROUP_NAME["$COMMAND_KEY"]="$COMMAND_GROUP $COMMAND_NAME"
        else
            _COMMANDS_GROUP_NAME["$COMMAND_KEY"]="$COMMAND_NAME"
        fi
        _COMMANDS_HELP_DESCRIPTION["$COMMAND_KEY"]="$COMMAND_HELP_DESCRIPTION"
        _COMMANDS_HELP_USAGE["$COMMAND_KEY"]="$COMMAND_HELP_USAGE"
        _COMMANDS_HELP_TEXT["$COMMAND_KEY"]="$COMMAND_HELP_TEXT"
    done
}

function load_commands {
    local COMMANDS_BASE_PATH="$1"

    for DIRECTORY in "$COMMANDS_BASE_PATH"/*; do
        # if is not a directory, skip
        [ ! -d "$DIRECTORY" ] && continue

        _load_commands_in_dir "$DIRECTORY"
    done
}

COMMAND_FOUND_KEY=
function find_command {
    local COMMAND="$1"
    local SUBCOMMAND="$2"

    # on empty command show help
    if [[ -z $COMMAND ]]; then
        COMMAND_FOUND_KEY=0
        return
    fi

    for key in "${!_COMMANDS_GROUP_NAME[@]}"; do
        if [[ "${_COMMANDS_GROUP_NAME[$key]}" == "$COMMAND $SUBCOMMAND" ]]; then
            COMMAND_FOUND_KEY="$key"
            return
        fi
        if [[ "${_COMMANDS_GROUP_NAME[$key]}" == "$COMMAND" ]]; then
            COMMAND_FOUND_KEY="$key"
            return
        fi
    done

    for group in "${!_GROUPS_NAMES[@]}"; do
        if [[ "${_GROUPS_NAMES[$group]}" == "$COMMAND" ]]; then
            if [[ -z "$SUBCOMMAND" ]]; then
                error "\nCommand $COMMAND not found\n\n"
            else
                error "\nCommand $COMMAND $SUBCOMMAND not found\n\n"
            fi

            message "Run "
            message "project help $COMMAND" "warning"
            message " to list available commands\n\n"
            exit 1
        fi
    done

    error "\nCommand $COMMAND not found\n\n"
    message "Run "
    message "project help" "warning"
    message " to list available commands\n\n"
    exit 1
}

function _do_run_command {
    local GROUP="$1"
    local COMMAND="$2"
    local FILE="$3"
    # shellcheck disable=SC2124
    local ARGUMENTS="${@:4}"

    if [[ -n $FILE ]]; then
        message "Loading $FILE\n"
        # shellcheck disable=SC1090
        source "$FILE"
    fi

    if [[ -n $GROUP ]]; then
        # echo "RUN $GROUP $COMMAND from $FILE"
        eval "run_${GROUP}_${COMMAND}" "$ARGUMENTS"
    elif [[ -n $COMMAND ]]; then
        # echo "RUN $COMMAND from $FILE"
        eval "run_${COMMAND}" "$ARGUMENTS"
    else
        eval "run_help" "$ARGUMENTS"
    fi
    exit 0
}

function run_command {
    local COMMAND="$1"
    local SUBCOMMAND="$2"

    if [[ -z $COMMAND_FOUND_KEY ]]; then
        die "Command not found (maybe you forgot to run 'find_command' before 'run_command')\n"
    fi

    if [[ -n ${_COMMANDS_GROUPS_PREFIX[$COMMAND_FOUND_KEY]} ]]; then
        # SUBCOMMAND
        _do_run_command "${_COMMANDS_GROUPS_PREFIX[$COMMAND_FOUND_KEY]}" "${_COMMANDS_NAMES[$COMMAND_FOUND_KEY]}" "${_COMMANDS_FILES[$COMMAND_FOUND_KEY]}" "${@:3}"
    else
        # COMMAND
        _do_run_command "${_COMMANDS_GROUPS_PREFIX[$COMMAND_FOUND_KEY]}" "${_COMMANDS_NAMES[$COMMAND_FOUND_KEY]}" "${_COMMANDS_FILES[$COMMAND_FOUND_KEY]}" "${@:2}"
    fi
}

function _debug_commands {
    echo
    echo "_COMMANDS_GROUP_NAME"
    for key in "${!_COMMANDS_GROUP_NAME[@]}"; do
        echo "$key: ${_COMMANDS_GROUP_NAME[$key]}"
    done

    echo
    echo "_COMMANDS_NAMES"
    for key in "${!_COMMANDS_NAMES[@]}"; do
        echo "$key: ${_COMMANDS_NAMES[$key]}"
    done

    echo
    echo "_COMMANDS_GROUP"
    for key in "${!_COMMANDS_GROUP[@]}"; do
        echo "$key: ${_COMMANDS_GROUP[$key]}"
    done

    echo
    echo "_COMMANDS_FILES"
    for key in "${!_COMMANDS_FILES[@]}"; do
        echo "$key: ${_COMMANDS_FILES[$key]}"
    done

    echo
    echo "_GROUPS_NAMES"
    for key in "${!_GROUPS_NAMES[@]}"; do
        warning "$key: ${_GROUPS_NAMES[$key]}\n"
    done

    echo
    echo "_GROUPS_TITLES"
    for key in "${!_GROUPS_TITLES[@]}"; do
        warning "$key: ${_GROUPS_TITLES[$key]}\n"
    done
}
