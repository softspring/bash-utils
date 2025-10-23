# Bash Functions Documentation: env.sh

This document describes the functions available in `functions/env.sh` for managing environment variables in shell scripts.

---

## Index
- [envFileContains](#envfilecontains)
- [loadEnvFile](#loadenvfile)
- [saveEnvVariable](#saveenvvariable)
- [removeEnvVariable](#removeenvvariable)
- [getDynamicVariableValue](#getdynamicvariablevalue)
- [replaceEnvVariables](#replaceenvvariables)

---

## Functions

### envFileContains
**Usage:** `envFileContains ENV_FILE PROPERTY`

- Checks if a property exists in an env file.
- Returns `1` if found, `0` otherwise.

---

### loadEnvFile
**Usage:** `loadEnvFile ENV_FILE [SILENCE]`

- Loads environment variables from a file.
- If `SILENCE=0`, prints a message.
- If the file does not exist, does nothing.

---

### saveEnvVariable
**Usage:** `saveEnvVariable ENV_FILE PROPERTY VALUE [SED_SEPARATOR]`

- Saves or updates an environment variable in a file.
- If the property exists, updates its value; otherwise, appends it.
- Optionally, a custom sed separator can be provided.
- Reloads the environment file after saving.

---

### removeEnvVariable
**Usage:** `removeEnvVariable ENV_FILE PROPERTY [SED_SEPARATOR]`

- Removes an environment variable from a file if it exists.
- Optionally, a custom sed separator can be provided.
- Reloads the environment file after removal.

---

### getDynamicVariableValue
**Usage:** `getDynamicVariableValue PREFIX NAME DEFAULT`

- Gets the value of a dynamic variable (e.g., `PREFIXNAME`).
- If not set, returns the provided default value.

---

### replaceEnvVariables
**Usage:** `replaceEnvVariables FILE`

- Replaces environment variables in a file using `envsubst`.
- Installs `envsubst` if not present (supports apt-get and apk).
- Overwrites the file with the substituted content.

---

## Notes
- These functions require standard Unix utilities and may depend on auxiliary functions such as `message`, `warning`, `die`, `replaceInFile`, and `deleteInFile`.
- Ensure you have the necessary permissions to modify environment files.

