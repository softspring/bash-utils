#!/bin/bash -e

# shellcheck disable=SC2034
COMMAND_NAME="config"
COMMAND_HELP_DESCRIPTION="Setups project, creating needed resources and configurations"
COMMAND_HELP_USAGE="project config"
COMMAND_HELP_TEXT="
  The ${ANSI_SUCCESS}project config${ANSI_END} script helps to config project for developers.

  It makes all needed tasks to start project development, for example:

    - select gcloud account and project for development
    - configure local domain in ${ANSI_WARNING}/etc/hosts${ANSI_END}
    - creates development gcloud service account
    - creates development gcloud buckets
    - configure docker ${ANSI_WARNING}compose.yaml${ANSI_END} for user
"

[ -z "${UTILS_TMP_PATH}" ] && echo "Run $COMMAND_NAME command with project script:" && echo "$ $COMMAND_HELP_USAGE" && exit 1

function config_prompt_gcloud_project {
    title "Configure gcloud"
    promptGcloudAccount "$GCLOUD_ACCOUNT"
    saveEnvVariable "$USER_PROJECT_CONFIG_FILE" "GCLOUD_ACCOUNT" "$GCLOUD_ACCOUNT"
    promptGcloudProject "$GCLOUD_PROJECT"
    saveEnvVariable "$USER_PROJECT_CONFIG_FILE" "GCLOUD_PROJECT" "$GCLOUD_PROJECT"
}

CONFIG_PROJECT_ID=default
CONFIG_PROJECT_SERVICE_ACCOUNT=0
CONFIG_PROJECT_SERVICE_ACCOUNT_KEY_PATH=
CONFIG_PROJECT_SERVICE_ACCOUNT_GRANT_ROLES=

function config_gcloud_service_account {
    # if not service account is needed, skip this step
    [[ "$CONFIG_PROJECT_SERVICE_ACCOUNT" == "0" ]] && return

    title "Configure gcloud service account"
    test "$SERVICE_ACCOUNT_ID" || saveEnvVariable "$USER_PROJECT_CONFIG_FILE" "SERVICE_ACCOUNT_ID" "$CONFIG_PROJECT_ID-dev-$USER"
    gcloudServiceAccountCreate "$GCLOUD_PROJECT" "$SERVICE_ACCOUNT_ID"

    if [[ "$CONFIG_PROJECT_SERVICE_ACCOUNT_KEY_PATH" != "" ]]; then
        gcloudServiceAccountKeyCreate "$GCLOUD_PROJECT" "$SERVICE_ACCOUNT_ID" "$CONFIG_PROJECT_SERVICE_ACCOUNT_KEY_PATH"
    fi

    for role in "${CONFIG_PROJECT_SERVICE_ACCOUNT_GRANT_ROLES[@]}"; do
        gcloudProjectGrantRoleServiceAccount "$GCLOUD_PROJECT" "$SERVICE_ACCOUNT_ID@$GCLOUD_PROJECT.iam.gserviceaccount.com" "$role"
    done
}

CONFIG_GCLOUD_MEDIA_PUBLIC_BUCKET=0
CONFIG_GCLOUD_MEDIA_PUBLIC_BUCKET_VARIABLE="IMAGES_BUCKET"

function config_gcloud_buckets {
    # if not service account is needed, skip this step
    [[ "$CONFIG_GCLOUD_MEDIA_PUBLIC_BUCKET" == "0" ]] && return

    title "Configure gcloud images bucket"
    test "${!CONFIG_GCLOUD_MEDIA_PUBLIC_BUCKET_VARIABLE}" || saveEnvVariable "$USER_PROJECT_CONFIG_FILE" "$CONFIG_GCLOUD_MEDIA_PUBLIC_BUCKET_VARIABLE" "$GCLOUD_PROJECT-local-$USER-images"
    gcloudBucketCreate "$GCLOUD_PROJECT" "$IMAGES_BUCKET"
    gcloudBucketSetPublic "$GCLOUD_PROJECT" "$IMAGES_BUCKET"
    gcloudBucketServiceAccountPermission "$GCLOUD_PROJECT" "$IMAGES_BUCKET" "$SERVICE_ACCOUNT_ID@$GCLOUD_PROJECT.iam.gserviceaccount.com" 'roles/storage.objectAdmin'
}

CONFIG_DEFAULT_DOMAIN=

function config_local_domains {
    title "Configure local domain"
    test "$LOCAL_DEFAULT_DOMAIN" || saveEnvVariable "$USER_PROJECT_CONFIG_FILE" "LOCAL_DEFAULT_DOMAIN" "$CONFIG_DEFAULT_DOMAIN"
    message "Check LOCAL_DEFAULT_DOMAIN env variable: $LOCAL_DEFAULT_DOMAIN\n"
    addDomainToEtcHosts "$LOCAL_DEFAULT_DOMAIN"
    addDomainToEtcHosts "www.$LOCAL_DEFAULT_DOMAIN"
}

function config_project {
    warning "Implement config_project function in your project to add any extra configuration steps\n"
}

function run_config {
    block "CONFIG"

    dockerComposeDown

    config_prompt_gcloud_project
    config_gcloud_service_account
    config_gcloud_buckets
    config_local_domains
    config_project

    success "\nDone! Project is configured.\n"
    message "\nRun ${ANSI_WARNING}project start${ANSI_END} to start (or restart) the project\n"
}
