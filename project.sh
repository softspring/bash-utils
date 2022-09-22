
function _show_help_files_in_dir {
  local LOAD_BASE_PATH="$1"
  local PARENT_SCRIPT="$2"

  for SCRIPT in "$LOAD_BASE_PATH"/*; do
        # SCRIPT_BASE_NAME=$(basename -- "$SCRIPT")
        SCRIPT_ID=$(basename -- "$SCRIPT" ".sh")

        # if is a directory, skip
        [ -d "$SCRIPT" ] && continue

        # skip tools scripts (starting with _)
        [ "${SCRIPT_ID:0:1}" == "_"  ] && continue

        # shellcheck disable=SC1090
        source "$SCRIPT"

        message "  $PARENT_SCRIPT$SCRIPT_ID               " "success" ; message "$COMMAND_HELP_DESCRIPTION\n"
    done
}

function show_help {
  local LOAD_BASE_PATH="$1"

  message "\nUsage:\n" "warning"
  message "\n  command [arguments]\n"
  message "\nAvailable commands:\n\n" "warning"
  message "  help                          " "success" ; message "Shows this info\n"

  _show_help_files_in_dir "$LOAD_BASE_PATH" ""

  for SCRIPT in "$LOAD_BASE_PATH"/*; do
      # SCRIPT_BASE_NAME=$(basename -- "$SCRIPT")
      SCRIPT_ID=$(basename -- "$SCRIPT" ".sh")

      # if is not a directory, skip
      [ ! -d "$SCRIPT" ] && continue

      source "$SCRIPT/_index.sh"
      title   "$COMMAND_HELP_TITLE"

      _show_help_files_in_dir "$SCRIPT" "$SCRIPT_ID "
  done

  message "\n"
}

function show_command_help {
  local LOAD_BASE_PATH="$1"
  local COMMAND="$2"
  local SUBCOMMAND="$3"

  if [[ -f "$LOAD_BASE_PATH/$COMMAND.sh" ]]
  then
    # shellcheck disable=SC1090
    source "$LOAD_BASE_PATH/$COMMAND.sh"
  elif [[ -d "$LOAD_BASE_PATH/$COMMAND" && -f "$LOAD_BASE_PATH/$COMMAND/$SUBCOMMAND.sh" ]]
  then
    # shellcheck disable=SC1090
    source "$LOAD_BASE_PATH/$COMMAND/$SUBCOMMAND.sh"
  else
    error "Command \"$COMMAND\" is not defined\n\n"
    message "Run "
    message "project help" "warning"
    message " to list available commands\n\n"
    exit 1
  fi

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

      message "Loading \"$SCRIPT_ID\" script\n"
      # shellcheck disable=SC1090
      source "$SCRIPT"
  done
}

if [[ "$1" == "help" || "$1" == "" ]]
then
  if [[ -n "$2" ]]
  then
    show_command_help "$SCRIPTS_DIR" "$2" "$3"
    exit
  fi

  show_help "$SCRIPTS_DIR"
  exit
fi

load_utils "$SCRIPTS_DIR"

if [[ -f "$SCRIPTS_DIR/$1.sh" ]]
then
  # shellcheck disable=SC1090
  source "$SCRIPTS_DIR/$1.sh"
  run "${@:2}"
  exit
fi

if [[ -d "$SCRIPTS_DIR/$1" && -f "$SCRIPTS_DIR/$1/$2.sh" ]]
then
  # shellcheck disable=SC1090
  source "$SCRIPTS_DIR/$1/$2.sh"
  run "${@:3}"
  exit
fi

error "\nCommand not found\n\n"
message "Run "
message "project help" "warning"
message " to list available commands\n\n"
exit 1