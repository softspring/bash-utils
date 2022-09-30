#!/bin/bash -e

function generateHash {
  local LENGTH=${1:-15}

  cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w ${1:-$LENGTH} | head -n 1
}

function addDomainToEtcHosts {
  local IP_DEFAULT='127.0.0.1'
  local DOMAIN=$1
  local IP=${2:-$IP_DEFAULT}

  DOMAIN_REGEX=$(echo $DOMAIN | sed 's/\./\\./' | sed 's/\-/\\-/')

  message "Checking $DOMAIN domain configuration in /etc/hosts: "
  if ! egrep -q "^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+.*\s$DOMAIN_REGEX" /etc/hosts
  then
    warning "MISSING\n"
    message "Add default $DOMAIN domain to /etc/hosts\n"
    sudo IP=$IP DOMAIN=$DOMAIN sh -c 'echo "$IP $DOMAIN" >> /etc/hosts'
  else
    success "OK\n"
  fi
}

function osType {
  case "$OSTYPE" in
    solaris*) echo "SOLARIS" ;;
    darwin*)  echo "OSX" ;;
    linux*)   echo "LINUX" ;;
    bsd*)     echo "BSD" ;;
    msys*)    echo "WINDOWS" ;;
    *)        echo "unknown: $OSTYPE" ;;
  esac
}

function isMac {
  if [[ $(osType) == 'OSX' ]]
  then
    echo 1
  else
    echo 0
  fi
}

function isLinux {
  if [[ $(osType) == 'LINUX' ]]
  then
    echo 1
  else
    echo 0
  fi
}

function openBrowser {
  local URL=$1

  if [[ $(isLinux) == 1 ]]
  then
    xdg-open "$URL" 2>/dev/null || true
  else
    open "$URL" 2>/dev/null || true
  fi
}

function dieIfNotMinimumVersion {
  local COMMAND_NAME=$1
  local REQUIRED_VERSION=$2
  local CURRENT_VERSION=${3:-$($COMMAND_NAME --version)}

  message "Checking $COMMAND_NAME version "

  CHECK_GT_REQUIRED_VERSION=$(printf '%s\n%s' "$REQUIRED_VERSION" "$CURRENT_VERSION" | sort -V -C && echo 1 || echo 0)
  if [[ $CHECK_GT_REQUIRED_VERSION == 1 ]]; then
    success "$CURRENT_VERSION\n"
  else
    die "$CURRENT_VERSION (required version >= $REQUIRED_VERSION)\n"
  fi
}