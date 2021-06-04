#!/bin/bash -e

# ######################################################################
# PROJECTS

function gcloudProjectCreate {
  local PROJECT=$1
  local PROJECT_NAME=${2-"$PROJECT"}
  local ORGANIZATION_ID=${3-''}

  if [ -z $ORGANIZATION_ID ]
  then
    if [ $(gcloud projects list --format "value(project_id)" | wc -l) -gt 0 ]
    then
      message "Project $PROJECT exists"
    else
      message "Create gcloud project"
      gcloud projects create $PROJECT --name="$PROJECT_NAME"
    fi
  else
    if [ $(gcloud projects list --filter=parent.id:$ORGANIZATION_ID --format "value(project_id)" | wc -l) -gt 0 ]
    then
      message "Project $PROJECT exists in $ORGANIZATION_ID organization"
    else
      message "Create gcloud project"
      gcloud projects create $PROJECT --organization=$ORGANIZATION_ID --name="$PROJECT_NAME"
    fi
  fi
}

# ######################################################################
# APPENGINE

function gcloudAppEngineCreate {
  local PROJECT=$1
  local REGION=$2

  gcloud app create --project=$PROJECT --region=$REGION || true
}

function gcloudAppEngineDeployApp {
  local PROJECT=$1
  local VERSION_NAME=$2
  local FILE=${3:-app.yaml}
  local ARGUMENTS=${4:-"--quiet --no-cache --no-promote"}

  if [ $VERSION_NAME ]
  then
    ARGUMENTS="--version=$VERSION_NAME $ARGUMENTS"
  fi

  gcloud app deploy $FILE $ARGUMENTS --project=$GCLOUD_PROJECT
}

function gcloudAppEngineDeployCron {
  local PROJECT=$1
  local FILE=${2:-cron.yaml}
  local ARGUMENTS=${3:-""}

  gcloud app deploy $FILE $ARGUMENTS --project=$GCLOUD_PROJECT
}

function gcloudAppEngineSetAllTraffic {
  local PROJECT=$1
  local VERSION_NAME=$2
  local SERVICE=${3:-default}

  gcloud app services set-traffic $SERVICE --splits $VERSION_NAME=1 --quiet --project=$PROJECT
}

# ######################################################################
# CLOUD SQL

function gcloudSqlInstanceCreate {
  local PROJECT=$1
  local INSTANCE_NAME=$2
  local MACHINE_TYPE=$3
  local REGION=$4
  local ROOT_PASSWORD=$5
  local ARGUMENTS=${6:-''}
  local DATABASE_VERSION=${7:-'MYSQL_5_7'}

  if [[ $(gcloudSqlInstanceExists $PROJECT $INSTANCE_NAME) == 0 ]]
  then
    message "Create SQL instance\n"
    gcloud sql instances create $INSTANCE_NAME \
      --tier=$MACHINE_TYPE \
      --region=$REGION \
      --storage-type=SSD \
      --database-version=$DATABASE_VERSION \
      --storage-auto-increase \
      --backup-start-time "00:00" \
      --root-password "$ROOT_PASSWORD" \
      --enable-bin-log \
      --maintenance-window-day "SUNDAY"	\
      --maintenance-window-hour	5 \
      --maintenance-release-channel	"production"	\
      --project=$PROJECT $ARGUMENTS
    #  --retained-backups-count		 \
    #  --retained-transaction-log-days		\
  else
    message "SQL instance is OK\n"
  fi
}

function gcloudSqlInstanceExists {
  local PROJECT=$1
  local INSTANCE_NAME=$2

  if [ $(gcloud sql instances list --format "value(name)" --filter "name:$INSTANCE_NAME" --project=$PROJECT | wc -l) -eq 1 ]
  then
    echo 1
  else
    echo 0
  fi
}

function gcloudSqlDatabaseCreate {
  local PROJECT=$1
  local INSTANCE_NAME=$2
  local DATABASE_NAME=$3

  if [ $(gcloud sql databases list --instance=$INSTANCE_NAME --format "value(name)" --filter "name:$DATABASE_NAME" --project=$PROJECT | wc -l) -eq 0 ]
  then
    message "Create database\n"
    gcloud sql databases create $DATABASE_NAME --instance=$INSTANCE_NAME \
      --project=$PROJECT \
      --charset=utf8mb4 \
      --collation=utf8mb4_unicode_ci
  else
    message "Database is OK\n"
  fi
}

function gcloudSqlUserCreate {
  local PROJECT=$1
  local INSTANCE_NAME=$2
  local USERNAME=$3
  local PASSWORD=$4

  if [[ $(gcloudSqlUserExists $PROJECT $INSTANCE_NAME $USERNAME) == 0 ]]
  then
    message "Create user\n"
    gcloud sql users create $USERNAME --instance=$INSTANCE_NAME \
      --project=$PROJECT \
      --password="$PASSWORD" \
      --host=%
  else
    message "User is OK\n"
  fi
}

function gcloudSqlUserExists {
  local PROJECT=$1
  local INSTANCE_NAME=$2
  local USERNAME=$3

  if [ $(gcloud sql users list --instance=$INSTANCE_NAME --format "value(name)" --filter "name:$USERNAME" --project=$PROJECT | wc -l) -eq 1 ]
  then
    echo 1
  else
    echo 0
  fi
}

# ######################################################################
# MEMORYSTORE

function gcloudRedisCreate {
  local PROJECT=$1
  local INSTANCE_NAME=$2
  local INSTANCE_SIZE=$3
  local INSTANCE_REGION=$4
  local INSTANCE_VERSION=$5
  local ARGUMENTS=${6:-''}

  if [ $(gcloud redis instances list --format "value(name)" --filter "name:$INSTANCE_NAME" --region=$INSTANCE_REGION --project=$PROJECT | wc -l) -eq 0 ]
  then
    message "Create $INSTANCE_NAME redis instance on $PROJECT\n"
    gcloud redis instances create $INSTANCE_NAME \
      --size=$INSTANCE_SIZE \
      --region=$INSTANCE_REGION \
      --redis-version=$INSTANCE_VERSION \
      --project=$PROJECT $ARGUMENTS
  else
    message "Redis $INSTANCE_NAME instance on $PROJECT is OK\n"
  fi
}

# ######################################################################
# SERVICE ACCOUNTS AND IAM

function gcloudServiceAccountCreate {
  local PROJECT=$1
  local SERVICE_ACCOUNT_ID=$2
  local DISPLAY_NAME="${3:-''}"

  message "Checking $SERVICE_ACCOUNT_ID service account in gcloud: "
  if [[ $(gcloudServiceAccountExists $PROJECT $SERVICE_ACCOUNT_ID) == 0 ]]
  then
    warning "MISSING\n"
    gcloud iam service-accounts create $SERVICE_ACCOUNT_ID \
      --display-name="$DISPLAY_NAME" \
      --project=$PROJECT
  else
    success "OK\n"
  fi
}

function gcloudServiceAccountExists {
  local PROJECT=$1
  local SERVICE_ACCOUNT_ID=$2

  if [ $(gcloud iam service-accounts list --format "value(name)" --filter "name:$SERVICE_ACCOUNT_ID" --project=$PROJECT | wc -l) -eq 1 ]
  then
    echo 1
  else
    echo 0
  fi
}

function gcloudServiceAccountKeyCreate {
  local PROJECT=$1
  local SERVICE_ACCOUNT_ID=$2
  local KEY_FILE=$3

  message "Checking service account key file at $KEY_FILE: "
  if [[ ! -f $KEY_FILE ]]
  then
    warning "MISSING\n"
    gcloud iam service-accounts keys create $KEY_FILE \
      --iam-account $SERVICE_ACCOUNT_ID@$PROJECT.iam.gserviceaccount.com \
      --project=$PROJECT
  else
    success "OK\n"
  fi
}

function gcloudProjectGrantRoleServiceAccount {
  local PROJECT=$1
  local SERVICE_ACCOUNT=$2
  local ROLE=$3

  message "Grant $ROLE to $SERVICE_ACCOUNT on $PROJECT\n"
  gcloud projects add-iam-policy-binding $PROJECT --member=serviceAccount:$SERVICE_ACCOUNT --role=$ROLE
}

function gcloudServiceAccountGrantRoleServiceAccount {
  local PROJECT=$1
  local RESOURCE_SERVICE_ACCOUNT=$2
  local SERVICE_ACCOUNT=$3
  local ROLE=$4

  message "Grant $_ROLE to $SERVICE_ACCOUNT on $RESOURCE_SERVICE_ACCOUNT\n"
  gcloud iam service-accounts add-iam-policy-binding $RESOURCE_SERVICE_ACCOUNT \
    --member=serviceAccount:$SERVICE_ACCOUNT \
    --role=$ROLE \
    --project=$PROJECT
}

function gcloudServiceAccountActivateAuth {
  local SERVICE_ACCOUNT=$1
  local KEY_FILE=$2

  gcloud auth activate-service-account $SERVICE_ACCOUNT --key-file $KEY_FILE
}

# ######################################################################
# SECRETS

function gcloudSecretsCreateFromFile {
  local PROJECT=$1
  local SECRET_NAME=$2
  local FILE=$3
  local ARGUMENTS=${4:-''}

  message "Checking $SECRET_NAME secret in $PROJECT: "
  if [[ $(gcloudSecretExists $PROJECT $SECRET_NAME) == 0 ]]
  then
    warning "MISSING\n"
    gcloud secrets create $SECRET_NAME \
     --project=$BUILD_PROJECT \
     --data-file=$FILE $ARGUMENTS
  else
    success "OK\n"
  fi
}

function gcloudSecretsUpsertFromFile {
  local PROJECT=$1
  local SECRET_NAME=$2
  local FILE=$3
  local ARGUMENTS=${4:-''}

  message "Checking $SECRET_NAME secret in $PROJECT: "
  if [[ $(gcloudSecretExists $PROJECT $SECRET_NAME) == 0 ]]
  then
    warning "MISSING\n"
    gcloud secrets create $SECRET_NAME \
     --project=$BUILD_PROJECT \
     --data-file=$FILE $ARGUMENTS
  else
    gcloud secrets version add $SECRET_NAME \
     --project=$BUILD_PROJECT \
     --data-file=$FILE $ARGUMENTS
    success "UPDATED\n"
  fi
}

function gcloudSecretsCreate {
  local PROJECT=$1
  local SECRET_NAME=$2
  local VALUE=$3
  local ARGUMENTS=${4:-''}

  message "Checking $SECRET_NAME secret in $PROJECT: "
  if [[ $(gcloudSecretExists $PROJECT $SECRET_NAME) == 0 ]]
  then
    warning "MISSING\n"
    echo -n $VALUE | gcloud secrets create $SECRET_NAME \
     --project=$BUILD_PROJECT \
     --data-file=- $ARGUMENTS
  else
    success "OK\n"
  fi
}

function gcloudSecretsUpsert {
  local PROJECT=$1
  local SECRET_NAME=$2
  local VALUE=$3
  local ARGUMENTS=${4:-''}

  message "Checking $SECRET_NAME secret in $PROJECT: "
  if [[ $(gcloudSecretExists $PROJECT $SECRET_NAME) == 0 ]]
  then
    warning "MISSING\n"
    echo -n $VALUE | gcloud secrets create $SECRET_NAME \
     --project=$BUILD_PROJECT \
     --data-file=- $ARGUMENTS
  else
    echo -n $VALUE | gcloud secrets version add $SECRET_NAME \
     --project=$BUILD_PROJECT \
     --data-file=- $ARGUMENTS
    success "UPDATED\n"
  fi
}

function gcloudSecretsDelete {
  local PROJECT=$1
  local SECRET_NAME=$2

  message "Checking $SECRET_NAME secret in $PROJECT: "
  if [[ $(gcloudSecretExists $PROJECT $SECRET_NAME) == 1 ]]
  then
    gcloud secrets delete $SECRET_NAME \
     --project=$BUILD_PROJECT -q
     success "DELETED\n"
  else
    success "IGNORED\n"
  fi
}

function gcloudSecretExists {
  local PROJECT=$1
  local SECRET_NAME=$2

  if [ $(gcloud secrets list --format "value(name)" --filter "name:$SECRET_NAME" --project=$PROJECT | wc -l) -eq 1 ]
  then
    echo 1
  else
    echo 0
  fi
}


# ######################################################################
# GCS

function gcloudBucketCreate {
  local PROJECT=$1
  local BUCKET_NAME=$2
  local TYPE=${3:-STANDARD}
  local REGION=${4:-EUROPE-WEST1}

  message "Checking $BUCKET_NAME bucket in $PROJECT: "
  if [[ $(gcloudBucketExists $PROJECT $BUCKET_NAME) == 0 ]]
  then
    warning "MISSING\n"
    gsutil mb -p $PROJECT -c $TYPE -l $REGION -b on gs://$BUCKET_NAME
  else
    success "OK\n"
  fi
}

function gcloudBucketExists {
  local PROJECT=$1
  local BUCKET_NAME=$2

  if [ $(gsutil ls -p $PROJECT | grep "gs://$BUCKET_NAME/" | wc -l) -eq 1 ]
  then
    echo 1
  else
    echo 0
  fi
}

function gcloudBucketServiceAccountPermission {
  local PROJECT=$1
  local BUCKET_NAME=$2
  local SERVICE_ACCOUNT_ID=$3
  local PERMISSION=$4

  gcloudBucketPermission $PROJECT $BUCKET_NAME "serviceAccount:$SERVICE_ACCOUNT_ID@$PROJECT.iam.gserviceaccount.com" $PERMISSION
}

function gcloudBucketSetPublic {
  local PROJECT=$1
  local BUCKET_NAME=$2

  gcloudBucketPermission $PROJECT $BUCKET_NAME allUsers objectViewer
}

function gcloudBucketPermission {
  local PROJECT=$1
  local BUCKET_NAME=$2
  local TO=$3
  local PERMISSION=$4

  gsutil iam ch $TO:$PERMISSION gs://$BUCKET_NAME
}

# ######################################################################
# APIS

function gcloudApiEnable {
  local PROJECT=$1
  local API=$2

  message "Enable $API API in $PROJECT\n"
  gcloud services enable $API.googleapis.com --project=$PROJECT
}

# ######################################################################
# VPC

function gcloudVpcConnectorCreate {
  local PROJECT=$1
  local CONNECTOR_NAME=$2
  local NETWORK=$3
  local REGION=$4
  local IP_RANGE=$5
  local ARGUMENTS=${6:-''}

  if [ $(gcloud compute networks vpc-access connectors list --format "value(name)" --filter "name:$CONNECTOR_NAME" --region=$REGION --project=$PROJECT | wc -l) -eq 0 ]
  then
    echo "Create $CONNECTOR_NAME vcp connector on $PROJECT"
    gcloud compute networks vpc-access connectors create $CONNECTOR_NAME \
      --network=$NETWORK \
      --region=$REGION \
      --range="$IP_RANGE" \
      --project=$PROJECT $ARGUMENTS
  else
    echo "VPC connector $CONNECTOR_NAME on $PROJECT is OK"
  fi
}
