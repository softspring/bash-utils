#!/bin/bash -e

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