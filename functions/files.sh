#!/usr/bin/env -S bash -e

# Creates an empty file if it does not exist
# Usage: createEmptyFile FILE_PATH
function createEmptyFile {
  local FILE_PATH=$1

  message "Checking $FILE_PATH file: "

  if [[ ! -f $FILE_PATH ]]
  then
    warning "MISSING\n"
    message "Create $FILE_PATH file\n"
    touch "$FILE_PATH"
  else
    success "OK\n"
  fi
}

# Checks if the checksum of a file matches a given variable
# Usage: checksumValid FILE_PATH CHECKSUM_VARIABLE_NAME
# Returns 1 if valid, 0 otherwise
function checksumValid {
  local FILE_PATH=$1
  local CHECKSUM_VARIABLE_NAME=$2

  local NEW_SHA1
  NEW_SHA1=$(sha1sum "$FILE_PATH"  | awk '{ print $1 }')
  local OLD_SHA1="${!CHECKSUM_VARIABLE_NAME}"

  if [[ $NEW_SHA1 == "$OLD_SHA1" ]]
  then
    echo 1
  else
    echo 0
  fi
}

# Creates a checksum for a file and optionally saves it to an env file
# Usage: createFileChecksum FILE_PATH CHECKSUM_VARIABLE_NAME [SAVE_VARIABLE_TO_FILE]
function createFileChecksum {
  local FILE_PATH=$1
  local CHECKSUM_VARIABLE_NAME=$2
  local SAVE_VARIABLE_TO_FILE=$3

  local SHA1
  SHA1=$(sha1sum "$FILE_PATH"  | awk '{ print $1 }')
  eval "$CHECKSUM_VARIABLE_NAME=$SHA1"

  if [ -n "$SAVE_VARIABLE_TO_FILE" ]
  then
    saveEnvVariable "$SAVE_VARIABLE_TO_FILE" "$CHECKSUM_VARIABLE_NAME" "${!CHECKSUM_VARIABLE_NAME}"
  fi
}

# Creates a file from a .dist template if it does not exist
# Usage: createFileFromDist FILE_PATH [DIST_FILE_PATH]
function createFileFromDist {
  local FILE_PATH=$1
  local DIST_FILE_PATH="${2:-$FILE_PATH.dist}"

  message "Checking $FILE_PATH file: "
  if [[ ! -f $FILE_PATH ]]
  then
      warning "MISSING\n"
      message "Create $FILE_PATH file from dist\n"
      cp "$DIST_FILE_PATH" "$FILE_PATH"
  else
    success "OK\n"
  fi
}

# Creates a file from a .dist template if missing or if the dist checksum has changed
# Usage: createFileFromDistWithChecksum FILE_PATH CHECKSUM_VARIABLE_NAME [SAVE_VARIABLE_TO_FILE] [DIST_FILE_PATH]
function createFileFromDistWithChecksum {
  local FILE_PATH=$1
  local CHECKSUM_VARIABLE_NAME=$2
  local SAVE_VARIABLE_TO_FILE=$3
  local DIST_FILE_PATH="${4:-$FILE_PATH.dist}"

  message "Checking $FILE_PATH file: "
  if [[ ! -f $FILE_PATH ]]
  then
      warning "MISSING\n"
      message "Create $FILE_PATH file from dist\n"
      cp "$DIST_FILE_PATH" "$FILE_PATH"
  elif [[ $(checksumValid "$DIST_FILE_PATH" "$CHECKSUM_VARIABLE_NAME") == 0 ]]
  then
    warning "HAS CHANGED\n"
    message "Recreate $FILE_PATH file from dist\n"
    cp "$DIST_FILE_PATH" "$FILE_PATH"
  else
    success "OK\n"
  fi

  createFileChecksum "$DIST_FILE_PATH" "$CHECKSUM_VARIABLE_NAME" "$SAVE_VARIABLE_TO_FILE"
}

# Comments lines matching a regex in a file
# Usage: comment REGEX FILE [COMMENT_MARK]
function comment() {
    local REGEX="${1:?}"
    local FILE="${2:?}"
    local COMMENT_MARK="${3:-#}"
    replaceInFile "^([ ]*)($REGEX)" "\\1$COMMENT_MARK\\2" "$FILE" ':' '-r'
}

# Uncomments lines matching a regex in a file
# Usage: uncomment REGEX FILE [COMMENT_MARK]
function uncomment() {
    local REGEX="${1:?}"
    local FILE="${2:?}"
    local COMMENT_MARK="${3:-#}"
    replaceInFile "^([ ]*)[$COMMENT_MARK]+[ ]?([ ]*$REGEX)" "\\1\\2" "$FILE" ':' '-r'
}