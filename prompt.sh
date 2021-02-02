#!/bin/bash -e

function promptValue {
  local VARIABLE_NAME=$1
  local DESCRIPTION=$2

  message "Checking $VARIABLE_NAME value: "
  if [[ -z ${!VARIABLE_NAME} ]]
  then
    warning "MISSING\n"

    if [[ -z $DESCRIPTION ]]
    then
      message $DESCRIPTION
    fi

    until [[ ${!VARIABLE_NAME} ]]
    do
      read -p "$VARIABLE_NAME: " $VARIABLE_NAME
    done
  else
    success "OK\n"
  fi
}

function promptGcloudProject {
  # is not local, it's global to return value
  GCLOUD_PROJECT=$1

  message "Checking GCLOUD_PROJECT project: "
  if [[ -z $GCLOUD_PROJECT ]]
  then
    warning "MISSING\n"
    echo "Authenticated as: $(gcloud config list account --format 'value(core.account)')"

    until [[ $GCLOUD_PROJECT ]]
    do
      read -p 'GCLOUD_PROJECT: ' GCLOUD_PROJECT

      if [[ -z $(gcloud projects list --format "value(project_id)" --filter "name:$GCLOUD_PROJECT") ]]
      then
        read -p "Project not found, do you want to create it? (Y/n)? " Yn
        if [[ $Yn == "Y" || $Yn == "" ]]
        then
          echo "TODO: Create $GCLOUD_PROJECT project in gcloud"
        else
          exit
          GCLOUD_PROJECT=""
        fi
      fi
    done
  else
    success "OK\n"
  fi
}
