#!/bin/bash -e

# ansi colors for mac
CLICOLOR=1
# colors
DEFAULT="\e[0m"
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
PURPLE="\e[35m"
CYAN="\e[36m"

STYLE_NORMAL="\033[0m"
STYLE_BOLD="\033[1m"

function message {
  local MESSAGE=$1
  local COLOR="${2:-default}"
  local STYLE="${3:-normal}"

  case "$COLOR" in
    "default" ) COLOR=$DEFAULT;;
    # style
    "success" ) COLOR=$GREEN;;
    "warning" ) COLOR=$YELLOW;;
    "error" ) COLOR=$RED;;
    # color
    "red" ) COLOR=$RED;;
    "green" ) COLOR=$GREEN;;
    "yellow" ) COLOR=$YELLOW;;
    "blue" ) COLOR=$BLUE;;
    "purple" ) COLOR=$PURPLE;;
    "cyan" ) COLOR=$CYAN;;
  esac

  case "$STYLE" in
    "normal" ) STYLE=$STYLE_NORMAL;;
    "bold" ) STYLE=$STYLE_BOLD;;
  esac

  printf "$COLOR$STYLE%b$STYLE_NORMAL$DEFAULT" "$MESSAGE";
}

function text {
  message "$PREFIX$1" $2
}

PREFIX=''

function block {
  message "\n***********************************************************\n" "default" "bold"
  message " $1\n" "default" "bold"
  message "***********************************************************\n" "default" "bold"
  PREFIX='    '
}

function title {
  message "\n$1\n" "default" "bold"
}

function success {
  message "$1" "success"
}

function warning {
  message "$1" "warning"
}

function error {
  message "$1" "error"
}

function replaceInFile {
  local EXPRESSION=$1
  local VALUE=$2
  local FILE_PATH=$3
  local SED_SEPARATOR="${4:-/}"

  sed "s${SED_SEPARATOR}${EXPRESSION}${SED_SEPARATOR}${VALUE}${SED_SEPARATOR}g" -i $FILE_PATH
}
