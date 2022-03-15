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

function promptGcloudAccount {
  # is not local, it's global to return value
  GCLOUD_ACCOUNT=$1

  message "Checking GCLOUD_ACCOUNT account: "
  if [[ -z $GCLOUD_ACCOUNT ]]
  then
    warning "MISSING\n"

    AUTHENTICATED_ACCOUNT=$(gcloud config list account --format 'value(core.account)')
    ACCOUNTS_LIST=( $(gcloud auth list  --format "value(account)") )
    ACCOUNTS_LIST_COUNT=${#ACCOUNTS_LIST[@]}

    until [[ $GCLOUD_ACCOUNT ]]
    do
      echo "Select one account:"
      ACCOUNT_INDEX=1
      for ACCOUNT_NAME in "${ACCOUNTS_LIST[@]}"
      do
          if [[ $AUTHENTICATED_ACCOUNT == $ACCOUNT_NAME ]]
          then
              echo "  $ACCOUNT_INDEX: $ACCOUNT_NAME (default)"
          else
              echo "  $ACCOUNT_INDEX: $ACCOUNT_NAME"
          fi

          ACCOUNT_INDEX=$((ACCOUNT_INDEX+1))
      done

      read -p 'GCLOUD_ACCOUNT: ' GCLOUD_ACCOUNT_NUMER

      if [[ -z $GCLOUD_ACCOUNT_NUMER ]]
      then
          echo "Selected $AUTHENTICATED_ACCOUNT"
          GCLOUD_ACCOUNT=$AUTHENTICATED_ACCOUNT
      else
          if [[ $GCLOUD_ACCOUNT_NUMER > $ACCOUNTS_LIST_COUNT || $GCLOUD_ACCOUNT_NUMER < 1 ]]
          then
              echo "Invalid selection $GCLOUD_ACCOUNT_NUMER"
          else
              GCLOUD_ACCOUNT=${ACCOUNTS_LIST[$((GCLOUD_ACCOUNT_NUMER-1))]}
              echo "Selected $GCLOUD_ACCOUNT"
          fi
      fi
    done
  else
    success "OK\n"
  fi
}
