#!/bin/bash -e

# http://www.andrewnoske.com/wiki/Bash_-_adding_color

# ansi colors for mac
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

  printf $(message_make "$COLOR" "$STYLE") "$MESSAGE"
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

  local SYSTEM="$(uname -s)"
  case "${SYSTEM}" in
    Linux*)
        sed "s${SED_SEPARATOR}${EXPRESSION}${SED_SEPARATOR}${VALUE}${SED_SEPARATOR}g" -i $FILE_PATH
        ;;
    Darwin*)
        if ! command -v gsed &> /dev/null
        then
            echo "brew install gnu-sed"
            exit 1
        fi

        gsed "s${SED_SEPARATOR}${EXPRESSION}${SED_SEPARATOR}${VALUE}${SED_SEPARATOR}g" -i $FILE_PATH
      ;;
    *)
      echo "Unknown $SYSTEM system"
  esac
}


function test_messages {
  MESSAGE=$(message_make "default") ; message "test " "default" ; echo $MESSAGE ; test "\e[${DEFAULT}m%b\e[0m" = "$MESSAGE"
  MESSAGE=$(message_make "success") ; message "test " "success" ; echo $MESSAGE ; test "\e[${GREEN}m%b\e[0m" = "$MESSAGE"
  MESSAGE=$(message_make "warning") ; message "test " "warning" ; echo $MESSAGE ; test "\e[${YELLOW}m%b\e[0m" = "$MESSAGE"
  MESSAGE=$(message_make "error") ; message "test " "error" ; echo $MESSAGE ; test "\e[${RED}m%b\e[0m" = "$MESSAGE"
  MESSAGE=$(message_make "red") ; message "test " "red" ; echo $MESSAGE ; test "\e[${RED}m%b\e[0m" = "$MESSAGE"
  MESSAGE=$(message_make "green") ; message "test " "green" ; echo $MESSAGE ; test "\e[${GREEN}m%b\e[0m" = "$MESSAGE"
  MESSAGE=$(message_make "yellow") ; message "test " "yellow" ; echo $MESSAGE ; test "\e[${YELLOW}m%b\e[0m" = "$MESSAGE"
  MESSAGE=$(message_make "blue") ; message "test " "blue" ; echo $MESSAGE ; test "\e[${BLUE}m%b\e[0m" = "$MESSAGE"
  MESSAGE=$(message_make "purple") ; message "test " "purple" ; echo $MESSAGE ; test "\e[${PURPLE}m%b\e[0m" = "$MESSAGE"
  MESSAGE=$(message_make "cyan") ; message "test " "cyan" ; echo $MESSAGE ; test "\e[${CYAN}m%b\e[0m" = "$MESSAGE"

  MESSAGE=$(message_make "default" "bold") ; message "test " "default" "bold" ; echo $MESSAGE ; test "\e[${STYLE_BOLD}m%b\e[0m" = "$MESSAGE"
  MESSAGE=$(message_make "default" "italic") ; message "test " "default" "italic" ; echo $MESSAGE ; test "\e[${STYLE_ITALIC}m%b\e[0m" = "$MESSAGE"
  MESSAGE=$(message_make "default" "underlined") ; message "test " "default" "underlined" ; echo $MESSAGE ; test "\e[${STYLE_UNDERLINED}m%b\e[0m" = "$MESSAGE"
  MESSAGE=$(message_make "default" "inverted") ; message "test " "default" "inverted" ; echo $MESSAGE ; test "\e[${STYLE_INVERTED}m%b\e[0m" = "$MESSAGE"

  MESSAGE=$(message_make "red" "bold") ; message "test " "red" "bold" ; echo $MESSAGE ; test "\e[$STYLE_BOLD%b\e[0m" = "$MESSAGE"
}
