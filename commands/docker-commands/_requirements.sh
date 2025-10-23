#!/usr/bin/env -S bash
# require docker >= 20.0
dieIfNotMinimumVersion 'docker' '20.0' "$(docker version --format '{{.Server.Version}}')"
# require docker compose >= 2.0
dieIfNotMinimumVersion 'docker compose' '2.0' "$(docker compose version --short)"