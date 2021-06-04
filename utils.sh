#!/bin/bash -e

function generateHash {
  local LENGTH=${1:-15}

  openssl rand -base64 $LENGTH
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