#!/bin/bash -e

source "$UTILS_TMP_PATH/env.sh"
source "$UTILS_TMP_PATH/files.sh"
source "$UTILS_TMP_PATH/gcloud.sh"
source "$UTILS_TMP_PATH/prompt.sh"
source "$UTILS_TMP_PATH/text.sh"
source "$UTILS_TMP_PATH/utils.sh"

message "Bash-utils ${ANSI_GREEN}$BASH_UTILS_VERSION${ANSI_END} in a $(osType) system\n"

HELP_SPACES_PAD=40

function load_utils {
  local LOAD_BASE_PATH="$1"

  for SCRIPT in "$LOAD_BASE_PATH"/*; do
      # SCRIPT_BASE_NAME=$(basename -- "$SCRIPT")
      SCRIPT_ID=$(basename -- "$SCRIPT" ".sh")

      # if is a directory, call recursively and continue
      [ -d "$SCRIPT" ] && load_utils "$SCRIPT" "$SCRIPT_ID" && continue

      # skip tools scripts (starting with _)
      [ "${SCRIPT_ID:0:1}" != "_"  ] && continue
      [ "$SCRIPT_ID" == "_index"  ] && continue

      # message "Loading \"$SCRIPT_ID\" script\n"
      # shellcheck disable=SC1090
      source "$SCRIPT"
  done
}

_COMMANDS_GROUPS=()
_COMMANDS_NAMES=()
_COMMANDS_FILES=()

function _load_commands_in_dir {
  local LOAD_BASE_PATH="$1"
  local COMMAND_GROUP="$2"

  for SCRIPT in "$LOAD_BASE_PATH"/*; do
      # shellcheck disable=SC2034
      # do not keep other commands variables
      COMMAND_NAME=

      # SCRIPT_BASE_NAME=$(basename -- "$SCRIPT")
      SCRIPT_ID=$(basename -- "$SCRIPT" ".sh")

      # if is a directory, skip
      [ -d "$SCRIPT" ] && continue

      # skip tools scripts (starting with _)
      [ "${SCRIPT_ID:0:1}" == "_"  ] && continue

      # shellcheck disable=SC1090
      source "$SCRIPT"

      _COMMANDS_GROUPS+=("$COMMAND_GROUP")
      _COMMANDS_NAMES+=("$COMMAND_NAME")
      _COMMANDS_FILES+=("$SCRIPT")
  done
}

function load_commands {
  local LOAD_BASE_PATH="$1"

  # load help command
  _COMMANDS_GROUPS+=("")
  _COMMANDS_NAMES+=("help")
  _COMMANDS_FILES+=("")

  _load_commands_in_dir "$LOAD_BASE_PATH"

  for SCRIPT in "$LOAD_BASE_PATH"/*; do
      # do not keep other commands documentation
      COMMAND_HELP_TITLE=

      # SCRIPT_BASE_NAME=$(basename -- "$SCRIPT")
      SCRIPT_ID=$(basename -- "$SCRIPT" ".sh")

      # if is not a directory, skip
      [ ! -d "$SCRIPT" ] && continue

      source "$SCRIPT/_index.sh"
      _load_commands_in_dir "$SCRIPT" "$COMMAND_GROUP"
  done
}

COMMAND_INDEX=
function find_command {
  local COMMAND="$1"
  local SUBCOMMAND="$2"
  local COMMAND_IS_GROUP=0

  for (( _COMMAND_INDEX=0; _COMMAND_INDEX<${#_COMMANDS_GROUPS[@]}; _COMMAND_INDEX++ ))
  do
    if [[ "${_COMMANDS_GROUPS[$_COMMAND_INDEX]}" == "$COMMAND" ]]
    then
      COMMAND_IS_GROUP=1

      if [[ "${_COMMANDS_GROUPS[$_COMMAND_INDEX]}" == "$COMMAND" && "${_COMMANDS_NAMES[$_COMMAND_INDEX]}" == "$SUBCOMMAND" ]]
      then
        COMMAND_INDEX="$_COMMAND_INDEX"
        return
      fi
    fi
  done

  for (( _COMMAND_INDEX=0; _COMMAND_INDEX<${#_COMMANDS_NAMES[@]}; _COMMAND_INDEX++ ))
  do
    if [[ "${_COMMANDS_NAMES[$_COMMAND_INDEX]}" == "$COMMAND" ]]
    then
      COMMAND_INDEX="$_COMMAND_INDEX"
      return
    fi
  done

  if [[ "$COMMAND_IS_GROUP" == "1" ]]
  then
    if [[ -z "$SUBCOMMAND" ]]
    then
      error "\nCommand $COMMAND not found\n\n"
    else
      error "\nCommand $COMMAND $SUBCOMMAND not found\n\n"
    fi

    message "Run "
    message "project help $COMMAND" "warning"
    message " to list available commands\n\n"
  else
    error "\nCommand $COMMAND not found\n\n"
    message "Run "
    message "project help" "warning"
    message " to list available commands\n\n"
  fi
  exit 1
}

function _show_help_files_in_dir {
  local LOAD_BASE_PATH="$1"
  local PARENT_SCRIPT="$2"

  [ -n "$PARENT_SCRIPT" ] && PARENT_SCRIPT="$PARENT_SCRIPT "

  for SCRIPT in "$LOAD_BASE_PATH"/*; do
        # shellcheck disable=SC2034
        # do not keep other commands documentation
        COMMAND_HELP_DESCRIPTION=

        # SCRIPT_BASE_NAME=$(basename -- "$SCRIPT")
        SCRIPT_ID=$(basename -- "$SCRIPT" ".sh")

        # if is a directory, skip
        [ -d "$SCRIPT" ] && continue

        # skip tools scripts (starting with _)
        [ "${SCRIPT_ID:0:1}" == "_"  ] && continue

        # shellcheck disable=SC1090
        source "$SCRIPT"

        message_pad "   $PARENT_SCRIPT$SCRIPT_ID" "$HELP_SPACES_PAD" "success"
        message "$COMMAND_HELP_DESCRIPTION\n"
    done
}

function _show_command_help {
  local INDEX="$1"

  if [[ -z "$INDEX" ]]
  then
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

  if [[ -n "$COMMAND_HELP_ARGUMENTS" ]]
  then
    message "\nArguments:\n" "warning"
    message "\n  $COMMAND_HELP_ARGUMENTS\n"
  fi

  if [[ -n "$COMMAND_HELP_OPTIONS" ]]
  then
    message "\nOptions:\n" "warning"
    message "\n  $COMMAND_HELP_OPTIONS\n"
  fi

  if [[ -n "$COMMAND_HELP_TEXT" ]]
  then
    message "\nHelp:\n" "warning"
    message "$COMMAND_HELP_TEXT\n"
  fi

  message "\n"
}

function run_help {
  local LOAD_BASE_PATH="$SCRIPTS_DIR"

  local HELP_COMMAND=$1
  local HELP_SUBCOMMAND=$2

  if [[ -n "$HELP_COMMAND" ]]
  then
    find_command "$HELP_COMMAND" "$HELP_SUBCOMMAND"
    _show_command_help "$COMMAND_INDEX"
    exit
  fi

  message "\nUsage:\n" "warning"
  message "\n  command [arguments]\n"
  message "\nAvailable commands:\n\n" "warning"
  message_pad "   help" "$HELP_SPACES_PAD" "success"
  message "Shows this info\n"

  _show_help_files_in_dir "$LOAD_BASE_PATH" ""

  for SCRIPT in "$LOAD_BASE_PATH"/*; do
      # do not keep other commands documentation
      COMMAND_HELP_TITLE=

      # SCRIPT_BASE_NAME=$(basename -- "$SCRIPT")
      SCRIPT_ID=$(basename -- "$SCRIPT" ".sh")

      # if is not a directory, skip
      [ ! -d "$SCRIPT" ] && continue

      source "$SCRIPT/_index.sh"
      title   "$COMMAND_HELP_TITLE"

      _show_help_files_in_dir "$SCRIPT" "$COMMAND_GROUP"
  done

  message "\n"
}

function _do_run_command {
  local GROUP="$1"
  local COMMAND="$2"
  local FILE="$3"
  # shellcheck disable=SC2124
  local ARGUMENTS="${@:4}"

  if [[ -n $FILE ]]
  then
    message "Loading $FILE\n"
    # shellcheck disable=SC1090
    source "$FILE"
  fi

  if [[ -n $GROUP ]]
  then
    # echo "RUN $GROUP $COMMAND from $FILE"
    eval "run_${GROUP}_${COMMAND}" "$ARGUMENTS"
  else
    # echo "RUN $COMMAND from $FILE"
    eval "run_${COMMAND}" "$ARGUMENTS"
  fi
  exit 0
}

function run_command {
  local INDEX="$1"
  local COMMAND="$2"
  local SUBCOMMAND="$3"

  if [[ -n ${_COMMANDS_GROUPS[$INDEX]} ]]
  then
    # SUBCOMMAND
    _do_run_command "${_COMMANDS_GROUPS[$INDEX]}" "${_COMMANDS_NAMES[$INDEX]}" "${_COMMANDS_FILES[$INDEX]}" "${@:4}"
  else
    # COMMAND
    _do_run_command "${_COMMANDS_GROUPS[$INDEX]}" "${_COMMANDS_NAMES[$INDEX]}" "${_COMMANDS_FILES[$INDEX]}" "${@:3}"
  fi
}

load_utils "$SCRIPTS_DIR"
load_commands "$SCRIPTS_DIR"
find_command "$@"
run_command "$COMMAND_INDEX" "$@"
exit