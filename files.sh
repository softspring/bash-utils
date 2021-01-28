#!/bin/bash -e

function createEmptyFile {
  local FILE_PATH=$1

  message "Checking $FILE_PATH file: "

  if [[ ! -f $FILE_PATH ]]
  then
    warning "MISSING\n"
    message "Create $FILE_PATH file\n"
    touch $FILE_PATH
  else
    success "OK\n"
  fi
}

function checksumValid {
  local FILE_PATH=$1
  local CHECKSUM_VARIABLE_NAME=$2

  NEW_SHA1=$(sha1sum $FILE_PATH  | awk '{ print $1 }')
  OLD_SHA1="${!CHECKSUM_VARIABLE_NAME}"

  if [[ $NEW_SHA1 == $OLD_SHA1 ]]
  then
    echo 1
  else
    echo 0
  fi
}

function createFileChecksum {
  local FILE_PATH=$1
  local CHECKSUM_VARIABLE_NAME=$2
  local SAVE_VARIABLE_TO_FILE=$3

  SHA1=$(sha1sum $FILE_PATH  | awk '{ print $1 }')
  eval $CHECKSUM_VARIABLE_NAME=$SHA1

  if [ ! -z $SAVE_VARIABLE_TO_FILE ]
  then
    saveEnvVariable .project $CHECKSUM_VARIABLE_NAME "${!CHECKSUM_VARIABLE_NAME}"
  fi
}

function createFileFromDist {
  local FILE_PATH=$1

  message "Checking $FILE_PATH file: "
  if [[ ! -f $FILE_PATH ]]
  then
      warning "MISSING\n"
      echo "Create $FILE_PATH file from dist"
      cp $FILE_PATH.dist $FILE_PATH
  else
    success "OK\n"
  fi
}

function createFileFromDistWithChecksum {
  local FILE_PATH=$1
  local CHECKSUM_VARIABLE_NAME=$2
  local SAVE_VARIABLE_TO_FILE=$3

  message "Checking $FILE_PATH file: "
  if [[ ! -f $FILE_PATH ]]
  then
      warning "MISSING\n"
      echo "Create $FILE_PATH file from dist"
      cp $FILE_PATH.dist $FILE_PATH
  elif [[ $(checksumValid "$FILE_PATH.dist" $CHECKSUM_VARIABLE_NAME) == 0 ]]
  then
    warning "HAS CHANGED\n"
    message "Recreate $FILE_PATH file from dist\n"
    cp $FILE_PATH.dist $FILE_PATH
  else
    success "OK\n"
  fi

  createFileChecksum "$FILE_PATH.dist" $CHECKSUM_VARIABLE_NAME $SAVE_VARIABLE_TO_FILE
}

function comment() {
    local REGEX="${1:?}"
    local FILE="${2:?}"
    local COMMENT_MARK="${3:-#}"
    sed -ri "s:^([ ]*)($REGEX):\\1$COMMENT_MARK\\2:" "$FILE"
}

function uncomment() {
    local REGEX="${1:?}"
    local FILE="${2:?}"
    local COMMENT_MARK="${3:-#}"
    sed -ri "s:^([ ]*)[$COMMENT_MARK]+[ ]?([ ]*$REGEX):\\1\\2:" "$FILE"
}