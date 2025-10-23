# Bash Functions Documentation: docker.sh

This document describes the functions available in `functions/docker.sh` for managing Docker Compose environments.

---

## Index
- [dockerComposeUp](#dockercomposeup)
- [dockerComposeRecreate](#dockercomposerecreate)
- [dockerComposeBuild](#dockercomposebuild)
- [dockerComposeDown](#dockercomposedown)
- [dockerComposeExec](#dockercomposeexec)
- [dockerContainerRunning](#dockercontainerrunning)
- [dieIfDockerContainerNotRunning](#dieifdockercontainernotrunning)
- [dockerGetNetworkGateway](#dockergetnetworkgateway)
- [dockerGetNetworkIP](#dockergetnetworkip)
- [dockerGetContainerName](#dockergetcontainername)
- [dockerGetNetworkSubnet](#dockergetnetworksubnet)

---

## Functions

### dockerComposeUp
**Usage:** `dockerComposeUp [container] [parameters]`

- Starts the Docker Compose environment in detached mode.
- If a container is specified, only that container is started.
- `parameters` allows passing additional arguments to `docker compose up`.

---

### dockerComposeRecreate
**Usage:** `dockerComposeRecreate [container]`

- Starts the Docker Compose environment recreating the containers.
- If a container is specified, only that container is recreated.

---

### dockerComposeBuild
**Usage:** `dockerComposeBuild [container]`

- Builds Docker Compose images.
- If a container is specified, only that container is built.

---

### dockerComposeDown
**Usage:** `dockerComposeDown [container]`

- Stops the Docker Compose environment and removes orphan containers.
- If a container is specified, only that container is stopped.

---

### dockerComposeExec
**Usage:** `dockerComposeExec [container] [command...]`

- Executes a command inside the specified container.

---

### dockerContainerRunning
**Usage:** `dockerContainerRunning [container]`

- Checks if a container is running.
- Returns `1` if running, `0` if not.

---

### dieIfDockerContainerNotRunning
**Usage:** `dieIfDockerContainerNotRunning [container]`

- Exits the script if the specified container is not running.

---

### dockerGetNetworkGateway
**Usage:** `dockerGetNetworkGateway [container] [network]`

- Gets the gateway IP of a container in a specific network.

---

### dockerGetNetworkIP
**Usage:** `dockerGetNetworkIP [container] [network]`

- Gets the IP address of a container in a specific network.

---

### dockerGetContainerName
**Usage:** `dockerGetContainerName [container]`

- Gets the container name as defined by Docker Compose.

---

### dockerGetNetworkSubnet
**Usage:** `dockerGetNetworkSubnet [network]`

- Gets the subnet of a Docker network.

---

## Notes
- These functions require Docker and Docker Compose to be installed.
- Some functions depend on auxiliary utilities such as `title`, `message`, and `error`.
