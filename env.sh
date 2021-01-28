#!/bin/bash -e

function loadEnvFile {
  local ENV_FILE=$1
  local SILENCE=${2:-0}

  if [ $SILENCE -eq 0 ]
  then
    message "Load env variables from $ENV_FILE\n"
  fi
  set -a; source $ENV_FILE; set +a
}

function saveEnvVariable {
  local ENV_FILE=$1
  local PROPERTY=$2
  local VALUE=$3
  local SED_SEPARATOR="${4:-/}"

  if egrep -q "^$PROPERTY=" $ENV_FILE
  then
    sed "s$SED_SEPARATOR^$PROPERTY=.*\$$SED_SEPARATOR$PROPERTY=$VALUE$SED_SEPARATOR" -i $ENV_FILE
    message "Saved $PROPERTY into $ENV_FILE\n"
  else
    echo "$PROPERTY=$VALUE" >> $ENV_FILE
    message "Saved new $PROPERTY into $ENV_FILE\n"
  fi

  loadEnvFile $ENV_FILE 1
}