#!/bin/bash -e

# http://www.andrewnoske.com/wiki/Bash_-_adding_color

# ansi colors for mac
# shellcheck disable=SC2034
CLICOLOR=1
# colors
DEFAULT="0"
RED="31"
GREEN="32"
YELLOW="33"
BLUE="34"
PURPLE="35"
CYAN="36"

STYLE_NORMAL="0"
STYLE_BOLD="1"
STYLE_ITALIC="3"
STYLE_UNDERLINED="4"
STYLE_INVERTED="7"

# FULL ANSI TAGS, TO BE USED IN TEXTS
ANSI_DEFAULT="\e[0m"
ANSI_RED="\e[31m"
ANSI_GREEN="\e[32m"
ANSI_YELLOW="\e[33m"
# shellcheck disable=SC2034
ANSI_BLUE="\e[34m"
# shellcheck disable=SC2034
ANSI_PURPLE="\e[35m"
# shellcheck disable=SC2034
ANSI_CYAN="\e[36m"
# shellcheck disable=SC2034
ANSI_ERROR="$ANSI_RED"
# shellcheck disable=SC2034
ANSI_SUCCESS="$ANSI_GREEN"
# shellcheck disable=SC2034
ANSI_WARNING="$ANSI_YELLOW"
# shellcheck disable=SC2034
ANSI_END="$ANSI_DEFAULT"

function message_make {
  local COLOR="${1:-default}"
  local STYLE="${2:-normal}"

  local ANSI=''

  case "$COLOR" in
    "default" ) ANSI='';;
    # style
    "success" ) ANSI=$GREEN;;
    "warning" ) ANSI=$YELLOW;;
    "error" ) ANSI=$RED;;
    # color
    "red" ) ANSI=$RED;;
    "green" ) ANSI=$GREEN;;
    "yellow" ) ANSI=$YELLOW;;
    "blue" ) ANSI=$BLUE;;
    "purple" ) ANSI=$PURPLE;;
    "cyan" ) ANSI=$CYAN;;
    *)
      echo "Invalid $COLOR color" 1>&2
      exit 1
  esac

  case "$STYLE" in
    "normal" ) STYLE=$STYLE_NORMAL;;
    "bold" )
      if [[ -z $ANSI ]]
      then
        ANSI="$STYLE_BOLD"
      else
        ANSI="$ANSI;$STYLE_BOLD"
      fi
      ;;
    "italic" )
      if [[ -z $ANSI ]]
      then
        ANSI="$STYLE_ITALIC"
      else
        ANSI="$ANSI;$STYLE_ITALIC"
      fi
      ;;
    "underlined" )
      if [[ -z $ANSI ]]
      then
        ANSI="$STYLE_UNDERLINED"
      else
        ANSI="$ANSI;$STYLE_UNDERLINED"
      fi
      ;;
    "inverted" )
      if [[ -z $ANSI ]]
      then
        ANSI="$STYLE_INVERTED"
      else
        ANSI="$ANSI;$STYLE_INVERTED"
      fi
      ;;
  esac

  if [[ -z $ANSI ]]
  then
    ANSI=$DEFAULT
  fi

  echo "\e[${ANSI}m%b\e[${DEFAULT}m" ;
}

function message {
  local MESSAGE=$1
  local COLOR=$2
  local STYLE=$3

  # shellcheck disable=SC2046
  # shellcheck disable=SC2059
  printf $(message_make "$COLOR" "$STYLE") "$MESSAGE"
}

# str_pad(
  #    string $string,
  #    int $length,
  #    string $pad_string = " ",
  #    int $pad_type = STR_PAD_RIGHT
  #): string
function message_pad {
  local MESSAGE=$1
  local PAD=$2
  local COLOR=${3:-default}
  local STYLE=${4:-normal}
  local PAD_CHAR=${5:-" "}
  local PAD_TYPE=${6:-"right"}

  [ "$PAD_TYPE" == 'right' ] && message "$MESSAGE" "$COLOR" "$STYLE"

  # shellcheck disable=SC2034
  for i in $(seq ${#MESSAGE} "$PAD"); do
     message "$PAD_CHAR"
  done

  [ "$PAD_TYPE" == 'left' ] && message "$MESSAGE" "$COLOR" "$STYLE"

  echo -n ""
}

function text {
  message "$PREFIX$1" "$2"
}

PREFIX=''

function block {
  message "\n"
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

function die {
  local MESSAGE=$1
  local EXIT_CODE=${2:-1}

  error "$MESSAGE"
  exit "$EXIT_CODE"
}

function dieIfEmpty {
  local VARIABLE=$1
  local MESSAGE=$2
  local EXIT_CODE=$3

  if [ ! $VARIABLE ]
  then
    die "$MESSAGE" "$EXIT_CODE"
  fi
}

function runSed {
  local COMMAND=$1

  if [ ! -z "$DEBUG_SED" ]
  then
    echo "sed/gsed $COMMAND"
  fi

  # shellcheck disable=SC2155
  local SYSTEM="$(uname -s)"
  case "${SYSTEM}" in
    Linux*)
        eval "sed $COMMAND"
        ;;
    Darwin*)
        if ! command -v gsed &> /dev/null
        then
            echo "brew install gnu-sed"
            exit 1
        fi

        eval "gsed $COMMAND"
      ;;
    *)
      echo "Unknown $SYSTEM system"
  esac
}

function replaceInFile {
  local EXPRESSION=$1
  local VALUE=$2
  local FILE_PATH=$3
  local SED_SEPARATOR="${4:-/}"
  local OPTIONS=$5

  runSed "\"s${SED_SEPARATOR}${EXPRESSION}${SED_SEPARATOR}${VALUE}${SED_SEPARATOR}g\" -i $OPTIONS $FILE_PATH"
}

function deleteInFile {
  local EXPRESSION=$1
  local FILE_PATH=$2
  local SED_SEPARATOR="${3:-/}"
  local OPTIONS=$4

  runSed "\"${SED_SEPARATOR}${EXPRESSION}${SED_SEPARATOR}d\" -i $OPTIONS $FILE_PATH"
}

function test_messages {
  MESSAGE=$(message_make "default") ; message "test " "default" ; echo "$MESSAGE" ; test "\e[${DEFAULT}m%b\e[0m" = "$MESSAGE"
  MESSAGE=$(message_make "success") ; message "test " "success" ; echo "$MESSAGE" ; test "\e[${GREEN}m%b\e[0m" = "$MESSAGE"
  MESSAGE=$(message_make "warning") ; message "test " "warning" ; echo "$MESSAGE" ; test "\e[${YELLOW}m%b\e[0m" = "$MESSAGE"
  MESSAGE=$(message_make "error") ; message "test " "error" ; echo "$MESSAGE" ; test "\e[${RED}m%b\e[0m" = "$MESSAGE"
  MESSAGE=$(message_make "red") ; message "test " "red" ; echo "$MESSAGE" ; test "\e[${RED}m%b\e[0m" = "$MESSAGE"
  MESSAGE=$(message_make "green") ; message "test " "green" ; echo "$MESSAGE" ; test "\e[${GREEN}m%b\e[0m" = "$MESSAGE"
  MESSAGE=$(message_make "yellow") ; message "test " "yellow" ; echo "$MESSAGE" ; test "\e[${YELLOW}m%b\e[0m" = "$MESSAGE"
  MESSAGE=$(message_make "blue") ; message "test " "blue" ; echo "$MESSAGE" ; test "\e[${BLUE}m%b\e[0m" = "$MESSAGE"
  MESSAGE=$(message_make "purple") ; message "test " "purple" ; echo "$MESSAGE" ; test "\e[${PURPLE}m%b\e[0m" = "$MESSAGE"
  MESSAGE=$(message_make "cyan") ; message "test " "cyan" ; echo "$MESSAGE" ; test "\e[${CYAN}m%b\e[0m" = "$MESSAGE"

  MESSAGE=$(message_make "default" "bold") ; message "test " "default" "bold" ; echo "$MESSAGE" ; test "\e[${STYLE_BOLD}m%b\e[0m" = "$MESSAGE"
  MESSAGE=$(message_make "default" "italic") ; message "test " "default" "italic" ; echo "$MESSAGE" ; test "\e[${STYLE_ITALIC}m%b\e[0m" = "$MESSAGE"
  MESSAGE=$(message_make "default" "underlined") ; message "test " "default" "underlined" ; echo "$MESSAGE" ; test "\e[${STYLE_UNDERLINED}m%b\e[0m" = "$MESSAGE"
  MESSAGE=$(message_make "default" "inverted") ; message "test " "default" "inverted" ; echo "$MESSAGE" ; test "\e[${STYLE_INVERTED}m%b\e[0m" = "$MESSAGE"

  MESSAGE=$(message_make "red" "bold") ; message "test " "red" "bold" ; echo "$MESSAGE" ; test "\e[$STYLE_BOLD%b\e[0m" = "$MESSAGE"
}
