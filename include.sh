#!/bin/bash -e

if [ -z $UTILS_TMP_PATH ]
then
  echo "Bash utils include tool"
else
  echo "Bash utils include tool (cache: $UTILS_TMP_PATH)"
fi

if [ "$1" == "all" ]
then
    set -- "env" "files" "gcloud" "prompt" "text" "utils"
fi

for TOOL in "$@"
do
    if [ -z $UTILS_TMP_PATH ]
    then
        echo " - include $TOOL"
        source <(curl -Ls https://raw.githubusercontent.com/softspring/bash-utils/main/$TOOL.sh)
    else 
        mkdir -p $UTILS_TMP_PATH
        if [ ! -f "$UTILS_TMP_PATH/$TOOL.sh" ]
        then
            echo " - downloading $TOOL"
            curl -Ls https://raw.githubusercontent.com/softspring/bash-utils/main/$TOOL.sh --output $UTILS_TMP_PATH/$TOOL.sh            
        else
            echo " - loading $TOOL (from cache)"
        fi
        
        source "$UTILS_TMP_PATH/$TOOL.sh"
    fi    
done
echo

