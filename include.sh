#!/bin/bash -e

echo "Bash utils include tool"

for TOOL in "$@"
do
    if [ -z $UTILS_TMP_PATH ]
    then
        echo " - include $TOOL"
        source <(curl -Ls https://raw.githubusercontent.com/softspring/bash-utils/main/$TOOL.sh)
    else 
        if [ ! -f "$UTILS_TMP_PATH/$TOOL.sh" ]
        then
            echo " - downloading $TOOL"
            curl -Ls https://raw.githubusercontent.com/softspring/bash-utils/main/$TOOL.sh --output $UTILS_TMP_PATH/$TOOL.sh            
        else
            echo " - loading $TOOL from $UTILS_TMP_PATH"
        fi
        
        source "$UTILS_TMP_PATH/$TOOL.sh"
    fi    
done


