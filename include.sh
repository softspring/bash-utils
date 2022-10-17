#!/bin/bash -e

## THIS FILE IS DEPRECATED
echo ""
printf "\033[1;33mTHIS bash-utils INCLUDING METHOD (include.sh) IS DEPRECATED, please see README and use new method \e[0m\n"
echo ""

if [[ -z $UTILS_TMP_PATH ]]
then
  echo "Bash utils include tool"
else
  echo "Bash utils include tool (cache: $UTILS_TMP_PATH)"
fi

if [[ "$1" == "all" ]]
then
    set -- "env" "files" "gcloud" "prompt" "text" "utils"
fi

LAST_GITHUB_COMMIT=$(curl "https://api.github.com/repos/softspring/bash-utils/branches/main" 2>&1 | grep sha | head -n1 | cut -d ":" -f2- | sed 's/[" ,]//g')
echo "Last github commit $LAST_GITHUB_COMMIT"

if [[ ! -z $UTILS_TMP_PATH && ! -z LAST_GITHUB_COMMIT ]]
then
  if [[ ! -f "$UTILS_TMP_PATH/.version" ]]
  then
    CURRENT_COMMIT=''
    echo "No current commit"
  else
    CURRENT_COMMIT=$(cat "$UTILS_TMP_PATH/.version")
    echo "Current commit $CURRENT_COMMIT"
  fi
fi

for TOOL in "$@"
do
    if [[ -z $UTILS_TMP_PATH ]]
    then
        echo " - include $TOOL"
        source <(curl -Ls https://raw.githubusercontent.com/softspring/bash-utils/main/$TOOL.sh)
    else 
        mkdir -p $UTILS_TMP_PATH
        if [[ ! -f "$UTILS_TMP_PATH/$TOOL.sh" ]]
        then
            echo " - downloading $TOOL"
            curl -Ls https://raw.githubusercontent.com/softspring/bash-utils/main/$TOOL.sh --output $UTILS_TMP_PATH/$TOOL.sh            
        else
            if [[ ! -z LAST_GITHUB_COMMIT && $LAST_GITHUB_COMMIT == $CURRENT_COMMIT ]]
            then
              echo " - loading $TOOL (from cache)"
            else
              echo " - upgrading $TOOL (to cache)"
              curl -Ls https://raw.githubusercontent.com/softspring/bash-utils/main/$TOOL.sh --output $UTILS_TMP_PATH/$TOOL.sh
            fi
        fi
        
        source "$UTILS_TMP_PATH/$TOOL.sh"
    fi    
done

if [[ ! -z $UTILS_TMP_PATH && ! -z LAST_GITHUB_COMMIT ]]
then
  echo $LAST_GITHUB_COMMIT > $UTILS_TMP_PATH/.version
fi

echo


