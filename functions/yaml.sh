#!/usr/bin/env -S bash -e

YAML_INDENT_SPACES=4

function yamlGetValue {
    local FILE="$1"
    local KEY="$2"

    # shellcheck disable=SC2046
    VALUE=$(docker run --user $(id -u):$(id -g) --rm -v .:/workdir mikefarah/yq "$KEY" "/workdir/$FILE")

    echo "$VALUE"
}

function yamlSetValue {
    local FILE="$1"
    local KEY="$2"
    local VALUE="$3"

    # shellcheck disable=SC2046
    docker run --user $(id -u):$(id -g) --rm -v .:/workdir mikefarah/yq "$KEY=\"$VALUE\"" "/workdir/$FILE" --inplace --indent $YAML_INDENT_SPACES
}

function yamlUnsetKey {
    local FILE="$1"
    local KEY="$2"

    # shellcheck disable=SC2046
    docker run --user $(id -u):$(id -g) --rm -v .:/workdir mikefarah/yq "del($KEY)" "/workdir/$FILE" --inplace --indent $YAML_INDENT_SPACES
}

function yamlRemoveArrayEntryByValue {
    local FILE="$1"
    local KEY="$2"
    local VALUE="$3"

    # shellcheck disable=SC2046
    docker run --user $(id -u):$(id -g) --rm -v .:/workdir mikefarah/yq "del($KEY[] | select(. == \"$VALUE\"))" "/workdir/$FILE" --inplace --indent $YAML_INDENT_SPACES
}
