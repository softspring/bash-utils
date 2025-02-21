#!/bin/bash

RESET_DATABASE_VOLUME_NAME=${RESET_DATABASE_VOLUME_NAME:-"db-data"}
RESET_DATABASE_DUMP_BUCKET=${RESET_DATABASE_DUMP_BUCKET:-"database-dump-bucket"}
RESET_DATABASE_DUMP_PATH=${RESET_DATABASE_DUMP_PATH:-"path-to-dump/"}
RESET_DATABASE_DUMP_FILE=${RESET_DATABASE_DUMP_FILE:-"dump.sql.gz"}
RESET_DATABASE_DUMP_TARGET_PATH=${RESET_DATABASE_DUMP_TARGET_PATH:-"docker-entrypoint-initdb.d/"}
RESET_DATABASE_DUMP_TARGET_FILE=${RESET_DATABASE_DUMP_TARGET_FILE:-"database-dump.sql.gz"}

function reset_database {
    title "Remove database volume"
    docker volume rm "$RESET_DATABASE_VOLUME_NAME" || true

    title "Remove previous database dumps"
    [ -d "$RESET_DATABASE_DUMP_TARGET_PATH" ] && rm -f "$RESET_DATABASE_DUMP_TARGET_PATH*"

    title "Download database dump"
    gcloud storage cp "gs://$RESET_DATABASE_DUMP_BUCKET/${RESET_DATABASE_DUMP_PATH}${RESET_DATABASE_DUMP_FILE}" "$RESET_DATABASE_DUMP_TARGET_PATH$RESET_DATABASE_DUMP_TARGET_FILE"

    title "Load database"
    docker compose up -d db
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

