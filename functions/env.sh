#!/usr/bin/env -S bash -e

# Checks if a property exists in an env file
# Usage: envFileContains ENV_FILE PROPERTY
# Returns 1 if found, 0 otherwise
function envFileContains {
  local ENV_FILE=$1
  local PROPERTY=$2

  if grep -E -q "^$PROPERTY=" "$ENV_FILE"
  then
    echo 1
  else
    echo 0
  fi
}

# Loads environment variables from a file
# Usage: loadEnvFile ENV_FILE [SILENCE]
# If SILENCE=0, prints a message
function loadEnvFile {
  local ENV_FILE=$1
  local SILENCE=${2:-0}

  if [ "$SILENCE" -eq 0 ]
  then
      message "Load env variables from ${ENV_FILE/$BASE_DIR\//}\n" "warning"
  fi
  set -a
  # shellcheck disable=SC1090
  if [ -f "$ENV_FILE" ]; then
    source "$ENV_FILE"
  fi
  set +a
}

# Saves or updates an environment variable in a file
# Usage: saveEnvVariable ENV_FILE PROPERTY VALUE [SED_SEPARATOR]
function saveEnvVariable {
  local ENV_FILE=$1
  local PROPERTY=$2
  local VALUE=$3
  local SED_SEPARATOR="${4:-/}"

  if grep -E -q "^$PROPERTY=" "$ENV_FILE"
  then
    replaceInFile "^$PROPERTY=.*\\\$" "$PROPERTY=$VALUE" "$ENV_FILE" "$SED_SEPARATOR"
    message "Saved $PROPERTY into $ENV_FILE\n"
  else
    echo "$PROPERTY=$VALUE" >> "$ENV_FILE"
    message "Saved new $PROPERTY into $ENV_FILE\n"
  fi

  loadEnvFile "$ENV_FILE" 1
}

# Removes an environment variable from a file
# Usage: removeEnvVariable ENV_FILE PROPERTY [SED_SEPARATOR]
function removeEnvVariable {
  local ENV_FILE=$1
  local PROPERTY=$2
  local SED_SEPARATOR="${3:-/}"

  if grep -E -q "^$PROPERTY=" "$ENV_FILE"
  then
    deleteInFile "^$PROPERTY=.*\\\$" "$ENV_FILE" "$SED_SEPARATOR"
    message "Removed $PROPERTY from $ENV_FILE\n"
  fi

  loadEnvFile "$ENV_FILE" 1
}

# Gets the value of a dynamic variable, or a default if not set
# Usage: getDynamicVariableValue PREFIX NAME DEFAULT
function getDynamicVariableValue {
    local PREFIX=$1
    local NAME=$2
    local DEFAULT=$3

    local VAR_NAME="${PREFIX}${NAME}"
    local VAR_VALUE="${!VAR_NAME}"

    if [ -n "$VAR_VALUE" ]; then
        echo "$VAR_VALUE"
    else
        echo "$DEFAULT"
    fi
}

# Replaces environment variables in a file using envsubst
# Usage: replaceEnvVariables FILE
function replaceEnvVariables {
  local FILE=$1

  if ! command -v envsubst &> /dev/null
  then
      warning "envsubst could not be found, trying to install\n"
      if command -v apt-get &> /dev/null; then
        apt-get update -y && apt-get install -y gettext-base || true
      elif command -v apk &> /dev/null; then
        apk add gettext || true
      fi
  fi

  if ! command -v envsubst &> /dev/null
  then
      die "Can not install envsubst\n"
  fi

  envsubst < "$FILE" > "$FILE.tmp"
  mv "$FILE.tmp" "$FILE"
  message "Replaced environment variables in $FILE\n"
}
