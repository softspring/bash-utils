#!/bin/bash -e
#> @command-name: open
#> @help-description: Opens local project
#> @help-usage: $MAIN_SCRIPT_NAME open
#> # The ${ANSI_SUCCESS}$MAIN_SCRIPT_NAME open${ANSI_END} script opens project in browser.

block 'OPEN'
gcloudSelectAccount "$GCLOUD_ACCOUNT"

open_messages
open_do
