# Bash Functions Documentation: files.sh

This document describes the functions available in `.dev/scripts/.bash-utils/functions/files.sh` for managing files and file checksums in shell scripts.

---

## Index
- [createEmptyFile](#createemptyfile)
- [checksumValid](#checksumvalid)
- [createFileChecksum](#createfilechecksum)
- [createFileFromDist](#createfilefromdist)
- [createFileFromDistWithChecksum](#createfilefromdistwithchecksum)
- [comment](#comment)
- [uncomment](#uncomment)

---

## Functions

### createEmptyFile
**Usage:** `createEmptyFile FILE_PATH`

- Creates an empty file if it does not exist.
- Prints a message indicating whether the file was created or already exists.

---

### checksumValid
**Usage:** `checksumValid FILE_PATH CHECKSUM_VARIABLE_NAME`

- Checks if the SHA1 checksum of a file matches the value stored in a variable.
- Returns `1` if valid, `0` otherwise.

---

### createFileChecksum
**Usage:** `createFileChecksum FILE_PATH CHECKSUM_VARIABLE_NAME [SAVE_VARIABLE_TO_FILE]`

- Calculates the SHA1 checksum of a file and assigns it to a variable.
- Optionally saves the checksum to an environment file if a path is provided.

---

### createFileFromDist
**Usage:** `createFileFromDist FILE_PATH [DIST_FILE_PATH]`

- Creates a file from a `.dist` template if it does not exist.
- If `DIST_FILE_PATH` is not provided, uses `FILE_PATH.dist` by default.

---

### createFileFromDistWithChecksum
**Usage:** `createFileFromDistWithChecksum FILE_PATH CHECKSUM_VARIABLE_NAME [SAVE_VARIABLE_TO_FILE] [DIST_FILE_PATH]`

- Creates a file from a `.dist` template if missing or if the template checksum has changed.
- Updates the checksum variable and optionally saves it to an environment file.

---

### comment
**Usage:** `comment REGEX FILE [COMMENT_MARK]`

- Comments lines matching a regex in a file.
- Uses the specified comment mark (default: `#`).

---

### uncomment
**Usage:** `uncomment REGEX FILE [COMMENT_MARK]`

- Uncomments lines matching a regex in a file.
- Uses the specified comment mark (default: `#`).

---

## Notes
- These functions require standard Unix utilities and may depend on auxiliary functions such as `message`, `warning`, `success`, `replaceInFile`, and `saveEnvVariable`.
- Ensure you have the necessary permissions to modify files.

