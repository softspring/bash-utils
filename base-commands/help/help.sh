#!/bin/bash

# shellcheck disable=SC2034
COMMAND_NAME="help"
COMMAND_HELP_DESCRIPTION="Shows help for commands"
COMMAND_HELP_USAGE="project help"
COMMAND_HELP_TEXT=""

HELP_SPACES_PAD=40

function _show_help_files_in_group {
    local GROUP_ID="$1"

    if [[ -z "$GROUP_ID" ]]; then
        return
    fi

    if [[ -n "${_GROUPS_TITLES[$GROUP_ID]}" ]]; then
        title "${_GROUPS_TITLES[$GROUP_ID]}"
    fi

    for command_key in "${!_COMMANDS_GROUP[@]}"; do
        if [[ "${_COMMANDS_GROUP[$command_key]}" == "$GROUP_ID" ]]; then
            message_pad "   ${_COMMANDS_GROUP_NAME[$command_key]}" "$HELP_SPACES_PAD" "success"
            # shellcheck disable=SC2153
            message "${_COMMANDS_HELP_DESCRIPTION[$command_key]}\n"
        fi
    done
}

function _show_command_help {
    local INDEX="$1"

    if [[ -z "$INDEX" ]]; then
        error "\nCommand \"$COMMAND\" is not defined\n\n"
        message "Run "
        message "project help" "warning"
        message " to list available commands\n\n"
        exit 1
    fi

    # shellcheck disable=SC1090
    source "${_COMMANDS_FILES[$INDEX]}"

    message "\nDescription:\n" "warning"
    message "\n  $COMMAND_HELP_DESCRIPTION\n"

    message "\nUsage:\n" "warning"
    message "\n  $COMMAND_HELP_USAGE\n"

    if [[ -n "$COMMAND_HELP_ARGUMENTS" ]]; then
        message "\nArguments:\n" "warning"
        message "\n  $COMMAND_HELP_ARGUMENTS\n"
    fi

    if [[ -n "$COMMAND_HELP_OPTIONS" ]]; then
        message "\nOptions:\n" "warning"
        message "\n  $COMMAND_HELP_OPTIONS\n"
    fi

    if [[ -n "$COMMAND_HELP_TEXT" ]]; then
        message "\nHelp:\n" "warning"
        message "$COMMAND_HELP_TEXT\n"
    fi

    message "\n"
}

function run_help {
    local HELP_COMMAND=$1
    local HELP_SUBCOMMAND=$2

    if [[ -n "$HELP_COMMAND" ]]; then
        # prevent error, find_command should fill it
        COMMAND_FOUND_KEY=
        find_command "$HELP_COMMAND" "$HELP_SUBCOMMAND"
        _show_command_help "$COMMAND_FOUND_KEY"
        exit
    fi

    message "\nUsage:\n" "warning"
    message "\n  command [arguments]\n"
    message "\nAvailable commands:\n\n" "warning"

    _show_help_files_in_group "help"

    for GROUP_KEY in "${!_GROUPS_NAMES[@]}"; do
        if [[ "$GROUP_KEY" != "help" ]]; then
            _show_help_files_in_group "$GROUP_KEY"
        fi
    done

    message "\n"
}
