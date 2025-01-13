#!/bin/bash -e

# TODO RUN COMMAND INSIDE DOCKER IMAGE

function yamlGetValue {
    local FILE="$1"
    local KEY="$2"

    VALUE=$(yq "$KEY" "$FILE")

    echo "value: $VALUE"
}

function yamlSetValue {
    local FILE="$1"
    local KEY="$2"
    local VALUE="$3"

    yq -iy "$KEY=$VALUE" "$FILE"
}

function yamlUnsetKey {
    echo "Unset key"
}

function yamlRemoveArrayEntryByValue {
    local FILE="$1"
    local KEY="$2"
    local VALUE="$3"

    # shellcheck disable=SC1087
    yq -yi "del($KEY[] | select(. == \"$VALUE\"))" "$FILE"
}
