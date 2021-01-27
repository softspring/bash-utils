#!/bin/bash -e

echo "Bash utils include tool"

for TOOL in "$@"
do
    echo "Include $TOOL"
    source <(curl -Ls https://raw.githubusercontent.com/softspring/bash-utils/main/$TOOL.sh)
done


