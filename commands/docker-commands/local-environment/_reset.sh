#!/usr/bin/env -S bash -e

RESET_DB_CONTAINER_NAME=${RESET_DB_CONTAINER_NAME:-"db"}
RESET_DATABASE_VOLUME_NAME=${RESET_DATABASE_VOLUME_NAME:-"db-data"}
RESET_DATABASE_DUMP_BUCKET=${RESET_DATABASE_DUMP_BUCKET:-"database-dump-bucket"}
RESET_DATABASE_DUMP_PATH=${RESET_DATABASE_DUMP_PATH:-"path-to-dump/"}
RESET_DATABASE_DUMP_FILE=${RESET_DATABASE_DUMP_FILE:-"dump.sql.gz"}
RESET_DATABASE_DUMP_TARGET_PATH=${RESET_DATABASE_DUMP_TARGET_PATH:-"docker-entrypoint-initdb.d/"}
RESET_DATABASE_DUMP_TARGET_FILE=${RESET_DATABASE_DUMP_TARGET_FILE:-"database-dump.sql.gz"}

function reset_database {
    title "Remove database volume $RESET_DATABASE_VOLUME_NAME"
    docker volume rm "$RESET_DATABASE_VOLUME_NAME" || true

    title "Remove previous database dumps"
    message "Removing files in $RESET_DATABASE_DUMP_TARGET_PATH\n"
    rm -f "$RESET_DATABASE_DUMP_TARGET_PATH$RESET_DATABASE_DUMP_TARGET_FILE"

    title "Download database dump"
    gcloud storage cp "gs://$RESET_DATABASE_DUMP_BUCKET/${RESET_DATABASE_DUMP_PATH}${RESET_DATABASE_DUMP_FILE}" "$RESET_DATABASE_DUMP_TARGET_PATH$RESET_DATABASE_DUMP_TARGET_FILE"

    title "Load database"
    docker compose up -d "$RESET_DB_CONTAINER_NAME"

    message "Loading database may take up to a couple of minutes.\n"
    message "Current time is $(date '+%T').\n"
    message "If it takes too long, you could check \"docker compose logs $RESET_DB_CONTAINER_NAME\" or docker inspect container to check healthchecks)\n"
    message "Waiting for database to be ready..."

    until [ "$(docker inspect -f '{{.State.Health.Status}}' "$(docker compose ps -q "$RESET_DB_CONTAINER_NAME")")" = "healthy" ]; do
      sleep 2
      message "."
    done

    success "\nDatabase is healthy.\n"
    message "Database loaded successfully at $(date '+%T').\n"
}

function reset_media {
    warning "Implement reset_media function in your project to reset images\n"
}

function reset_docker_up {
    title "Starting Docker environment..."
    dockerComposeUp "" ""
}

function reset_post_start {
    warning "Implement reset_post_start function in your project to run post start commands\n"
}

