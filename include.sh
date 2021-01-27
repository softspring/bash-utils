#!/bin/bash -e

echo "Bash utils include tool $UTILS_TMP_PATH"

for TOOL in "$@"
do
    if [ -z $UTILS_TMP_PATH ]
    then
        echo "Include $TOOL"
        source <(curl -Ls https://raw.githubusercontent.com/softspring/bash-utils/main/$TOOL.sh)
    else 
        if [ ! -f "$UTILS_TMP_PATH/$TOOL.sh" ]
        then
            curl -Ls https://raw.githubusercontent.com/softspring/bash-utils/main/$TOOL.sh --output $UTILS_TMP_PATH/$TOOL.sh            
        fi
        
        source "$UTILS_TMP_PATH/$TOOL.sh"
    fi    
done


