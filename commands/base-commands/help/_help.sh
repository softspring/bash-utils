#!/usr/bin/env -S bash -e

HELP_SPACES_PAD=40

function _show_help_files_in_group_by_key {
    local GROUP_KEY="$1"

    if [[ -z "$GROUP_KEY" ]]; then
        return
    fi

    for g in "${!_GROUPS_KEYS[@]}"; do
        if [[ "${_GROUPS_KEYS[$g]}" == "$GROUP_KEY" ]]; then
            _show_help_files_in_group_by_index "$g"
        fi
    done
}

function _show_help_files_in_group_by_index {
    local INDEX="$1"

    GROUP_KEY="${_GROUPS_KEYS[$INDEX]}"
    GROUP_DESCRIPTION="${_GROUPS_DESCRIPTIONS[$INDEX]}"

    title "$GROUP_DESCRIPTION"

    for c in "${!_COMMANDS_GROUPS[@]}"; do
        COMMAND_GROUP="${_COMMANDS_GROUPS[$c]}"

        if [[ "$COMMAND_GROUP" == "$GROUP_KEY" ]]; then
            if [[ "${_COMMANDS_NAMES_PREFIX[$c]}" != "" ]]; then
                COMMAND_NAME="${_COMMANDS_NAMES_PREFIX[$c]} ${_COMMANDS_NAMES[$c]}"
            else
                COMMAND_NAME="${_COMMANDS_NAMES[$c]}"
            fi
            message_pad "   $COMMAND_NAME" "$HELP_SPACES_PAD" "success"
            # shellcheck disable=SC2153
            message "${_COMMANDS_DESCRIPTIONS[$c]}\n"
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
#    source "${__COMMANDS_FILES[$INDEX]}"

    message "\nDescription:\n" "warning"
    message "\n  ${_COMMANDS_DESCRIPTIONS[$INDEX]}\n"

    message "\nUsage:\n" "warning"
    message "\n  $(eval "echo \"${_COMMANDS_USAGES[$INDEX]}\"")\n"

#    if [[ -n "$COMMAND_HELP_ARGUMENTS" ]]; then
#        message "\nArguments:\n" "warning"
#        message "\n  $COMMAND_HELP_ARGUMENTS\n"
#    fi
#
#    if [[ -n "$COMMAND_HELP_OPTIONS" ]]; then
#        message "\nOptions:\n" "warning"
#        message "\n  $COMMAND_HELP_OPTIONS\n"
#    fi

    if [[ -n "${_COMMANDS_TEXTS[$INDEX]}" ]]; then
        message "\nHelp:\n" "warning"
        message "\n$(eval "echo \"${_COMMANDS_TEXTS[$INDEX]}\"")\n"
    fi

    message "\n"
}
