#!/usr/bin/env -S bash -e
#> @command-name: help
#> @help-description: Shows help for commands
#> @help-usage: $MAIN_SCRIPT_NAME help [command]

HELP_COMMAND_INDEX=
for i in "${!_COMMANDS_KEYS[@]}"; do
    if [[ "${_COMMANDS_NAMES_PREFIX[$i]}" == "$1" && "${_COMMANDS_NAMES[$i]}" == "$2" ]]; then
        HELP_COMMAND_INDEX=$i
        shift 2
        break
    elif [[ -z "${_COMMANDS_NAMES_PREFIX[$i]}" && "${_COMMANDS_NAMES[$i]}" == "$1" ]]; then
        HELP_COMMAND_INDEX=$i
        shift
        break
    fi
done

if [[ -n "$HELP_COMMAND_INDEX" ]]; then
    # prevent error, find_command should fill it
    _show_command_help "$HELP_COMMAND_INDEX"
    exit
fi

message "\nUsage:\n" "warning"
message "\n  command [arguments]\n"
message "\nAvailable commands:\n\n" "warning"

_show_help_files_in_group_by_key "help"

for g in "${!_GROUPS_KEYS[@]}"; do
    GROUP_KEY="${_GROUPS_KEYS[$g]}"
    if [[ "$GROUP_KEY" != "help" ]]; then
        _show_help_files_in_group_by_key "$GROUP_KEY"
    fi
done

message "\n"
