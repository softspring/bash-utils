#!/bin/bash -e

function loadEnvFile {
  local ENV_FILE=$1
  local SILENCE=${2:-0}

  if [ "$SILENCE" -eq 0 ]
  then
    message "Load env variables from $ENV_FILE\n"
  fi
  set -a;
  # shellcheck disable=SC1090
  source "$ENV_FILE";
  set +a
}

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

function removeEnvVariable {
  local ENV_FILE=$1
  local PROPERTY=$2
  local SED_SEPARATOR="${4:-/}"

  if grep -E -q "^$PROPERTY=" "$ENV_FILE"
  then
    deleteInFile "^$PROPERTY=.*\$" "$ENV_FILE" "$SED_SEPARATOR"
    message "Removed $PROPERTY from $ENV_FILE\n"
  fi

  loadEnvFile "$ENV_FILE" 1
}

function getDynamicVariableValue {
    PREFIX=$1
    NAME=$2
    DEFAULT=$3

    local VAR_NAME="$PREFIX$NAME"
    local VAR_VALUE="${!VAR_NAME}"

    if [ "$VAR_VALUE" ]; then
        echo "${!VAR_NAME}"
    else
        echo "$DEFAULT"
    fi
}

# replaceEnvVariables $FILE
function replaceEnvVariables {
  local FILE=$1

  if ! command -v envsubst &> /dev/null
  then
      warning "envsubst could not be found, trying to install\n"
      # shellcheck disable=SC2015
      apt-get update -y && apt-get install -y gettext-base || true
      apk add gettext || true
  fi

  if ! command -v envsubst &> /dev/null
  then
      die "Can not install envsubst\n"
  fi

  envsubst < "$FILE" > "$FILE.tmp"
  mv "$FILE.tmp" "$FILE"
  message "Replaced environment variables in $FILE\n"
}
